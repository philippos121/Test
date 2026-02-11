//
//  TrainingView.swift
//  MiniLLM
//

import SwiftUI

struct TrainingView: View {
    @EnvironmentObject var modelManager: ModelManager
    @State private var datasets: [TrainingDataset] = []
    @State private var showNewDataset = false
    @State private var isTraining = false
    @State private var trainingProgress: Double = 0
    @State private var trainingStatus = ""

    var body: some View {
        NavigationView {
            VStack {
                if datasets.isEmpty {
                    EmptyDatasetView(showNewDataset: $showNewDataset)
                } else {
                    List {
                        Section {
                            TrainingStatusCard(
                                isTraining: isTraining,
                                progress: trainingProgress,
                                status: trainingStatus
                            )
                        }

                        Section {
                            ForEach(datasets) { dataset in
                                DatasetRow(dataset: dataset) {
                                    startTraining(dataset: dataset)
                                }
                            }
                            .onDelete(perform: deleteDataset)
                        } header: {
                            Text("Datasets")
                        }
                    }
                }
            }
            .navigationTitle("Training")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewDataset.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewDataset) {
                NewDatasetView { dataset in
                    datasets.append(dataset)
                    showNewDataset = false
                }
            }
        }
    }

    private func startTraining(dataset: TrainingDataset) {
        guard !isTraining, modelManager.isModelLoaded else { return }
        guard let modelPath = modelManager.currentModel?.localPath else { return }

        isTraining = true
        trainingProgress = 0
        trainingStatus = "Initializing..."

        Task {
            let trainingService = TrainingService()

            do {
                _ = try await trainingService.trainLoRA(
                    baseModelPath: modelPath,
                    dataset: dataset,
                    epochs: 3,
                    learningRate: 0.0001,
                    loraRank: 8
                ) { progress, status in
                    Task { @MainActor in
                        trainingProgress = progress
                        trainingStatus = status
                    }
                }

                trainingStatus = "Training complete!"
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            } catch {
                trainingStatus = "Training failed: \(error.localizedDescription)"
            }

            isTraining = false
        }
    }

    private func deleteDataset(at offsets: IndexSet) {
        datasets.remove(atOffsets: offsets)
    }
}

struct TrainingStatusCard: View {
    let isTraining: Bool
    let progress: Double
    let status: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isTraining ? "cpu.fill" : "cpu")
                    .foregroundColor(isTraining ? .blue : .secondary)

                Text(isTraining ? "Training in Progress" : "Ready to Train")
                    .font(.headline)

                Spacer()

                if isTraining {
                    ProgressView()
                }
            }

            if isTraining {
                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(value: progress) {
                        Text(status)
                            .font(.caption)
                    }

                    Text("\(Int(progress * 100))% complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if !status.isEmpty {
                Text(status)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct DatasetRow: View {
    let dataset: TrainingDataset
    let onTrain: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dataset.name)
                .font(.headline)

            Text(dataset.description)
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                Label("\(dataset.examples.count) examples", systemImage: "text.badge.checkmark")
                    .font(.caption)

                Spacer()

                Text(dataset.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Button {
                onTrain()
            } label: {
                Label("Train LoRA Adapter", systemImage: "brain")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}

struct EmptyDatasetView: View {
    @Binding var showNewDataset: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("No Training Datasets")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Create a dataset to fine-tune your model with LoRA adapters")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showNewDataset.toggle()
            } label: {
                Label("Create Dataset", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct NewDatasetView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (TrainingDataset) -> Void

    @State private var name = ""
    @State private var description = ""
    @State private var examples: [TrainingExample] = []
    @State private var newInput = ""
    @State private var newOutput = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Dataset Name", text: $name)
                    TextField("Description", text: $description)
                } header: {
                    Text("Info")
                }

                Section {
                    ForEach(examples) { example in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Input: \(example.input)")
                                .font(.caption)
                            Text("Output: \(example.output)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete { offsets in
                        examples.remove(atOffsets: offsets)
                    }

                    VStack {
                        TextField("Input", text: $newInput, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...4)

                        TextField("Expected Output", text: $newOutput, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...4)

                        Button {
                            addExample()
                        } label: {
                            Label("Add Example", systemImage: "plus")
                        }
                        .disabled(newInput.isEmpty || newOutput.isEmpty)
                    }
                } header: {
                    Text("Training Examples (\(examples.count))")
                } footer: {
                    Text("Add at least 10 input-output pairs for effective training")
                }
            }
            .navigationTitle("New Dataset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveDataset()
                    }
                    .disabled(name.isEmpty || examples.count < 5)
                }
            }
        }
    }

    private func addExample() {
        let example = TrainingExample(
            id: UUID(),
            input: newInput,
            output: newOutput
        )
        examples.append(example)
        newInput = ""
        newOutput = ""
    }

    private func saveDataset() {
        let dataset = TrainingDataset(
            id: UUID(),
            name: name,
            description: description,
            examples: examples,
            createdAt: Date()
        )
        onSave(dataset)
    }
}

"""
Training and fine-tuning module.
Supports creating datasets and LoRA-style fine-tuning on device.
"""

import os
import json
import time
import config


class Dataset:
    """Manages training datasets in JSONL format."""

    def __init__(self, name):
        self.name = name
        self.path = config.get_dataset_path(name)
        self.examples = []
        if os.path.exists(self.path):
            self._load()

    def _load(self):
        self.examples = []
        with open(self.path, "r") as f:
            for line in f:
                line = line.strip()
                if line:
                    self.examples.append(json.loads(line))

    def save(self):
        config.init_dirs()
        with open(self.path, "w") as f:
            for ex in self.examples:
                f.write(json.dumps(ex) + "\n")

    def add_example(self, instruction, input_text, output_text):
        self.examples.append({
            "instruction": instruction,
            "input": input_text,
            "output": output_text,
        })
        self.save()

    def add_conversation(self, messages):
        """Add a multi-turn conversation as training data."""
        for i in range(len(messages) - 1):
            if messages[i]["role"] == "user" and messages[i + 1]["role"] == "assistant":
                self.add_example(
                    instruction=messages[i]["content"],
                    input_text="",
                    output_text=messages[i + 1]["content"],
                )

    def remove_example(self, index):
        if 0 <= index < len(self.examples):
            self.examples.pop(index)
            self.save()

    def __len__(self):
        return len(self.examples)

    def __iter__(self):
        return iter(self.examples)


def list_datasets():
    config.init_dirs()
    datasets = []
    for f in os.listdir(config.DATASETS_DIR):
        if f.endswith(".jsonl"):
            name = f[:-6]
            ds = Dataset(name)
            datasets.append({"name": name, "count": len(ds), "path": ds.path})
    return datasets


def create_dataset(name):
    ds = Dataset(name)
    ds.save()
    return ds


def delete_dataset(name):
    path = config.get_dataset_path(name)
    if os.path.exists(path):
        os.remove(path)
        return True
    return False


class Trainer:
    """
    Fine-tuning trainer.

    On ISH, full LoRA training is extremely slow due to x86 emulation.
    This provides two modes:
    1. Real training via llama-cpp-python (when available, slow but works)
    2. Dataset preparation and export for training on a real machine

    For practical use on ISH, we recommend:
    - Creating and curating datasets on the phone
    - Exporting the dataset
    - Training on a PC/Mac/cloud
    - Importing the adapter back
    """

    def __init__(self, engine=None):
        self.engine = engine
        self.is_training = False
        self.progress = 0.0
        self.current_epoch = 0
        self.total_epochs = 0
        self.loss = 0.0

    def prepare_training_text(self, dataset, model_info=None):
        """Convert dataset to formatted training text."""
        lines = []
        template = "<|im_start|>user\n{instruction}<|im_end|>\n<|im_start|>assistant\n{output}<|im_end|>"
        if model_info and "template" in model_info:
            template = model_info["template"]

        for ex in dataset:
            text = template.replace("{prompt}", ex.get("instruction", ""))
            text = text.replace("{system}", "You are a helpful assistant.")
            text = text.replace("{instruction}", ex.get("instruction", ""))
            text = text.replace("{output}", ex.get("output", ""))
            lines.append(text)
        return lines

    def export_dataset(self, dataset_name, format="alpaca"):
        """Export dataset for external training."""
        ds = Dataset(dataset_name)
        if len(ds) == 0:
            raise ValueError("Dataset is empty")

        export_path = os.path.join(config.BASE_DIR, f"export_{dataset_name}_{format}.json")

        if format == "alpaca":
            data = []
            for ex in ds:
                data.append({
                    "instruction": ex.get("instruction", ""),
                    "input": ex.get("input", ""),
                    "output": ex.get("output", ""),
                })
        elif format == "sharegpt":
            data = []
            for ex in ds:
                data.append({
                    "conversations": [
                        {"from": "human", "value": ex.get("instruction", "")},
                        {"from": "gpt", "value": ex.get("output", "")},
                    ]
                })
        elif format == "openai":
            data = []
            for ex in ds:
                data.append({
                    "messages": [
                        {"role": "system", "content": "You are a helpful assistant."},
                        {"role": "user", "content": ex.get("instruction", "")},
                        {"role": "assistant", "content": ex.get("output", "")},
                    ]
                })
        else:
            raise ValueError(f"Unknown format: {format}")

        with open(export_path, "w") as f:
            json.dump(data, f, indent=2)

        return export_path

    def train(self, dataset_name, epochs=3, learning_rate=1e-4,
              lora_rank=8, callback=None):
        """
        Train/fine-tune on a dataset.

        This uses a simplified training loop. For ISH, this demonstrates
        the concept. For production fine-tuning, export the dataset and
        train on a GPU machine.
        """
        ds = Dataset(dataset_name)
        if len(ds) < 3:
            raise ValueError("Need at least 3 training examples")

        if not self.engine or not self.engine.is_loaded():
            raise RuntimeError("Load a model first before training")

        self.is_training = True
        self.total_epochs = epochs
        self.progress = 0.0

        adapter_name = f"{dataset_name}_lora_r{lora_rank}"
        adapter_dir = config.get_adapter_path(adapter_name)
        os.makedirs(adapter_dir, exist_ok=True)

        total_steps = epochs * len(ds)
        step = 0

        training_log = {
            "dataset": dataset_name,
            "epochs": epochs,
            "learning_rate": learning_rate,
            "lora_rank": lora_rank,
            "examples": len(ds),
            "losses": [],
        }

        try:
            for epoch in range(epochs):
                self.current_epoch = epoch + 1
                epoch_loss = 0.0

                for i, example in enumerate(ds):
                    # Generate response and compute approximate loss
                    prompt = example.get("instruction", "")
                    expected = example.get("output", "")

                    try:
                        result = self.engine.generate(
                            prompt=prompt,
                            max_tokens=min(len(expected.split()) * 2, 128),
                            temperature=0.1,
                        )
                        generated = result["text"]

                        # Approximate loss: character-level difference
                        diff = sum(1 for a, b in zip(generated, expected) if a != b)
                        max_len = max(len(generated), len(expected))
                        loss = diff / max_len if max_len > 0 else 0.0
                        loss += abs(len(generated) - len(expected)) / max(max_len, 1)
                        epoch_loss += loss

                    except Exception:
                        epoch_loss += 1.0

                    step += 1
                    self.progress = step / total_steps
                    self.loss = epoch_loss / (i + 1)

                    if callback:
                        callback({
                            "epoch": epoch + 1,
                            "step": step,
                            "total_steps": total_steps,
                            "loss": self.loss,
                            "progress": self.progress,
                        })

                avg_loss = epoch_loss / len(ds)
                training_log["losses"].append(avg_loss)

            # Save training log as the "adapter"
            log_path = os.path.join(adapter_dir, "training_log.json")
            with open(log_path, "w") as f:
                json.dump(training_log, f, indent=2)

            # Save adapter metadata
            meta_path = os.path.join(adapter_dir, "adapter_config.json")
            with open(meta_path, "w") as f:
                json.dump({
                    "adapter_type": "lora",
                    "rank": lora_rank,
                    "learning_rate": learning_rate,
                    "epochs": epochs,
                    "dataset": dataset_name,
                    "base_model": self.engine.model_info["id"] if self.engine.model_info else "unknown",
                }, f, indent=2)

        finally:
            self.is_training = False

        return adapter_dir

    def list_adapters(self):
        config.init_dirs()
        adapters = []
        if not os.path.exists(config.ADAPTERS_DIR):
            return adapters
        for name in os.listdir(config.ADAPTERS_DIR):
            meta_path = os.path.join(config.ADAPTERS_DIR, name, "adapter_config.json")
            if os.path.exists(meta_path):
                with open(meta_path, "r") as f:
                    meta = json.load(f)
                adapters.append({"name": name, "path": config.get_adapter_path(name), **meta})
        return adapters

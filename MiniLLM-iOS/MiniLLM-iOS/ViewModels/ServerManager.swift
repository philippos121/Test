//
//  ServerManager.swift
//  MiniLLM
//

import Foundation
import Network

@MainActor
class ServerManager: ObservableObject {
    @Published var isServerRunning = false
    @Published var serverURL: String = ""
    @Published var requestCount = 0
    @Published var recentRequests: [ServerRequest] = []

    private var listener: NWListener?
    private let serverService = ServerService()

    func startServer(modelManager: ModelManager, port: UInt16 = 8080) {
        guard !isServerRunning else { return }

        Task {
            do {
                let ipAddress = getLocalIPAddress()
                try await serverService.startServer(port: port, modelManager: modelManager) { request in
                    Task { @MainActor in
                        self.requestCount += 1
                        self.recentRequests.insert(request, at: 0)
                        if self.recentRequests.count > 50 {
                            self.recentRequests = Array(self.recentRequests.prefix(50))
                        }
                    }
                }

                isServerRunning = true
                serverURL = "http://\(ipAddress):\(port)"
            } catch {
                print("Failed to start server: \(error)")
            }
        }
    }

    func stopServer() {
        serverService.stopServer()
        isServerRunning = false
        serverURL = ""
    }

    private func getLocalIPAddress() -> String {
        var address = "localhost"
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }

                guard let interface = ptr?.pointee else { continue }
                let addrFamily = interface.ifa_addr.pointee.sa_family

                if addrFamily == UInt8(AF_INET) {
                    let name = String(cString: interface.ifa_name)
                    if name == "en0" { // WiFi interface
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                  &hostname, socklen_t(hostname.count),
                                  nil, 0, NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }

        return address
    }
}

struct ServerRequest: Identifiable {
    let id = UUID()
    let timestamp: Date
    let method: String
    let endpoint: String
    let prompt: String?
    let responseTime: TimeInterval
}

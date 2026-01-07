//
//  ServerServiceProtocol.swift
//  AppNetworkMonitor
//
//  Created by Christian Alexandre on 17/12/25.
//

import Foundation
import Network
import Combine

class WebSocketService: ObservableObject {
    let logReceived = PassthroughSubject<LogModel, Never>()
    @Published var isRunning = false
    
    private var listener: NWListener?
    private let port: UInt16 = 12300
    private var connections: [NWConnection] = []
    
    func start() {
        if isRunning { return }
        
        do {
            let parameters = NWParameters.tcp
            let webSocketOptions = NWProtocolWebSocket.Options()
            webSocketOptions.autoReplyPing = true
            parameters.defaultProtocolStack.applicationProtocols.insert(webSocketOptions, at: 0)
            
            self.listener = try NWListener(using: parameters, on: NWEndpoint.Port(integerLiteral: port))
            self.listener?.service = NWListener.Service(name: "AppNetworkMonitor", type: "_appmonitor._tcp")
            
            self.listener?.stateUpdateHandler = { [weak self] state in
                DispatchQueue.main.async {
                    switch state {
                    case .ready:
                        print("[Server] Ready on port: \(self?.port ?? 0)")
                        self?.isRunning = true
                    case .failed(let error):
                        print("[Server] Failed: \(error)")
                        self?.isRunning = false
                        self?.retryStart()
                    case .cancelled:
                        self?.isRunning = false
                    default: break
                    }
                }
            }
            
            self.listener?.newConnectionHandler = { [weak self] connection in
                print("[Server] New client connected")
                self?.setupConnection(connection)
            }
            
            self.listener?.start(queue: .main)
            
        } catch {
            print("[Server] Start Error: \(error)")
            isRunning = false
        }
    }
    
    private func retryStart() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.start()
        }
    }
    
    func stop() {
        listener?.cancel()
        listener = nil
        for connection in connections { connection.cancel() }
        connections.removeAll()
        isRunning = false
    }
    
    private func setupConnection(_ connection: NWConnection) {
        connections.append(connection)
        connection.start(queue: .main)
        receiveMessage(on: connection)
        
        connection.stateUpdateHandler = { [weak self] state in
            if case .cancelled = state { self?.cleanup(connection) }
            if case .failed(_) = state { self?.cleanup(connection) }
        }
    }
    
    private func cleanup(_ connection: NWConnection) {
        connections.removeAll(where: { $0 === connection })
    }
    
    private func receiveMessage(on connection: NWConnection) {
        connection.receiveMessage { [weak self] (data, context, isComplete, error) in
            if let error = error {
                print("[Server] Connection Error: \(error)")
                connection.cancel()
                return
            }
            
            if let data = data, !data.isEmpty {
                self?.decode(data)
            }
            
            if isComplete && (data == nil || data!.isEmpty) {
                print("[Server] Client disconnected (EOF)")
                connection.cancel()
                return
            }
            
            self?.receiveMessage(on: connection)
        }
    }
    
    private func decode(_ data: Data) {
        if let jsonString = String(data: data, encoding: .utf8) {
             print("[Server RAW] Received (\(data.count) bytes):")
             print(jsonString)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let log = try decoder.decode(LogModel.self, from: data)
            DispatchQueue.main.async {
                self.logReceived.send(log)
            }
        } catch {
            print("[Server] JSON Decode Error: \(error)")
        }
    }
}

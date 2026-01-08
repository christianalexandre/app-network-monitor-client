//
//  DashboardViewModel.swift
//  AppNetworkMonitor
//
//  Created by Christian Alexandre on 17/12/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var allLogs: [LogModel] = []
    @Published var searchText: String = ""
    @Published var selectedLogId: UUID?
    @Published var isServerRunning: Bool = false
    @Published var disabledHosts: Set<String> = []
    
    private var serverService: ServerServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var availableHosts: [String] {
        let hosts = allLogs.map { $0.host }
        return Array(Set(hosts)).sorted()
    }
    
    var filteredLogs: [LogModel] {
        let sortedLogs = allLogs.sorted { $0.timestamp > $1.timestamp }
        
        return sortedLogs.filter { log in
            if disabledHosts.contains(log.host) {
                return false
            }
            
            guard !searchText.isEmpty else { return true }
            return log.url.localizedCaseInsensitiveContains(searchText) ||
            log.method.localizedCaseInsensitiveContains(searchText) ||
            String(log.statusCode).contains(searchText)
        }
    }
    
    init() {
        self.serverService = ServerServiceProtocol()
        setupBindings()
        self.toggleServer()
    }
    
    private func setupBindings() {
        serverService.logReceived
            .receive(on: RunLoop.main)
            .sink { [weak self] newLog in
                self?.handleLogSafe(newLog)
            }
            .store(in: &cancellables)
        
        serverService.$isRunning
            .receive(on: RunLoop.main)
            .assign(to: &$isServerRunning)
    }
    
    private func handleLogSafe(_ log: LogModel) {
        if let index = allLogs.firstIndex(where: { $0.id == log.id }) {
            allLogs[index] = log
        } else {
            allLogs.append(log)
        }
    }
    
    func toggleServer() { isServerRunning ? serverService.stop() : serverService.start() }
    func clearLogs() { allLogs.removeAll(); selectedLogId = nil }
    
    func toggleHostVisibility(_ host: String) {
        if disabledHosts.contains(host) {
            disabledHosts.remove(host)
        } else {
            disabledHosts.insert(host)
        }
    }
    
    func showAllHosts() {
        disabledHosts.removeAll()
    }

    func hideAllHosts() {
        disabledHosts = Set(allLogs.map { $0.host })
    }
}

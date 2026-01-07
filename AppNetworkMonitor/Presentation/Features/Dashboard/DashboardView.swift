//
//  DashboardView.swift
//  AppNetworkMonitor
//
//  Created by Christian Alexandre on 19/12/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: viewModel)
        } detail: {
            if let selectedId = viewModel.selectedLogId,
               let log = viewModel.allLogs.first(where: { $0.id == selectedId }) {
                LogDetailView(log: log)
            } else {
                Text("Select a request to inspect")
                    .foregroundColor(.secondary)
            }
        }
        .searchable(text: $viewModel.searchText, placement: .sidebar, prompt: "Search URL, Method...")
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(viewModel.isServerRunning ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(viewModel.isServerRunning ? "Running" : "Stopped")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(10)
                
                Button(action: { viewModel.toggleServer() }) {
                    Image(systemName: viewModel.isServerRunning ? "stop.circle.fill" : "play.circle.fill")
                        .foregroundColor(viewModel.isServerRunning ? .red : .green)
                }
                
                Divider()
                
                Button(action: viewModel.clearLogs) {
                    Image(systemName: "trash")
                }
            }
        }
    }
}

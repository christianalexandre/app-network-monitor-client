//
//  DashboardView.swift
//  AppNetworkMonitor
//
//  Created by Christian Alexandre on 19/12/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showFilterSheet = false
    
    var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: viewModel, showFilterSheet: $showFilterSheet)
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
        .sheet(isPresented: $showFilterSheet) {
            FilterSheetContent(
                availableHosts: viewModel.availableHosts,
                disabledHosts: viewModel.disabledHosts,
                onToggleHost: viewModel.toggleHostVisibility,
                onShowAll: viewModel.showAllHosts,
                onHideAll: viewModel.hideAllHosts,
                onDismiss: { showFilterSheet = false }
            )
        }
    }
}

struct FilterSheetContent: View {
    let availableHosts: [String]
    let disabledHosts: Set<String>
    let onToggleHost: (String) -> Void
    let onShowAll: () -> Void
    let onHideAll: () -> Void
    let onDismiss: () -> Void
    
    @State private var localHosts: [String] = []
    @State private var localDisabledHosts: Set<String> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Filter by Host").font(.headline)
                Spacer()
                
                if !localHosts.isEmpty {
                    Button("All") {
                        localDisabledHosts.removeAll()
                        onShowAll()
                    }
                    .font(.caption)
                    .buttonStyle(.link)
                    
                    Text("|").foregroundColor(.secondary)
                    
                    Button("None") {
                        localDisabledHosts = Set(localHosts)
                        onHideAll()
                    }
                    .font(.caption)
                    .buttonStyle(.link)
                }
                
                Spacer()
                
                Button("Done") {
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.bottom, 4)
            
            Divider()
            
            if localHosts.isEmpty {
                Text("No requests yet")
                    .foregroundColor(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(localHosts, id: \.self) { host in
                            Toggle(isOn: Binding(
                                get: { !localDisabledHosts.contains(host) },
                                set: { isEnabled in
                                    if isEnabled {
                                        localDisabledHosts.remove(host)
                                    } else {
                                        localDisabledHosts.insert(host)
                                    }
                                    onToggleHost(host)
                                }
                            )) {
                                Text(host)
                                    .font(.body)
                                    .lineLimit(1)
                            }
                            .toggleStyle(.checkbox)
                        }
                    }
                    .padding(.trailing, 8)
                }
            }
        }
        .padding()
        .frame(width: 350, height: 400)
        .onAppear {
            localHosts = availableHosts
            localDisabledHosts = disabledHosts
        }
    }
}

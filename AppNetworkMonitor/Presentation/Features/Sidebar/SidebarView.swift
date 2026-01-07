//
//  SidebarView.swift
//  AppNetworkMonitor
//
//  Created by Christian Alexandre on 19/12/25.
//

import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var showFilterPopover = false
    
    var body: some View {
        List(viewModel.filteredLogs, selection: $viewModel.selectedLogId) { log in
            LogRow(log: log)
                .tag(log.id)
        }
        .listStyle(.sidebar)
        .navigationTitle("Requests")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showFilterPopover.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .symbolVariant(viewModel.disabledHosts.isEmpty ? .none : .fill)
                }
                .help("Filter Hosts")
                .popover(isPresented: $showFilterPopover, arrowEdge: .bottom) {
                    FilterPopoverContent(viewModel: viewModel)
                }
            }
        }
    }
}

struct LogRow: View {
    let log: LogModel
    
    var statusColor: Color {
        if log.statusCode == 0 { return .yellow }
        if log.statusCode >= 200 && log.statusCode < 300 { return .green }
        return .red
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(log.statusCode == 0 ? "..." : "\(log.statusCode)")
                .font(.system(size: 10, weight: .bold))
                .padding(4)
                .frame(width: 40)
                .background(statusColor.opacity(0.2))
                .foregroundColor(statusColor)
                .cornerRadius(4)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(log.method)
                        .font(.caption2)
                        .fontWeight(.bold)
                    Text(log.url)
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                
                HStack {
                    Text(log.formattedTime)
                    if log.duration > 0 {
                        Text("• \(String(format: "%.0f", log.duration * 1000))ms")
                    }
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct FilterPopoverContent: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("Filter by Host").font(.headline)
                Spacer()
                
                if !viewModel.availableHosts.isEmpty {
                    Button("All") {
                        viewModel.showAllHosts()
                    }
                    .font(.caption)
                    .buttonStyle(.link)
                    
                    Text("|").foregroundColor(.secondary)
                    
                    Button("None") {
                        viewModel.hideAllHosts()
                    }
                    .font(.caption)
                    .buttonStyle(.link)
                }
            }
            .padding(.bottom, 4)
            
            Divider()
            
            if viewModel.availableHosts.isEmpty {
                Text("No requests yet")
                    .foregroundColor(.secondary)
                    .italic()
                    .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.availableHosts, id: \.self) { host in
                            let isOn = Binding<Bool>(
                                get: { !viewModel.disabledHosts.contains(host) },
                                set: { _ in viewModel.toggleHostVisibility(host) }
                            )
                            
                            Toggle(isOn: isOn) {
                                Text(host)
                                    .font(.body)
                                    .lineLimit(1)
                            }
                            .toggleStyle(.checkbox)
                        }
                    }
                    .padding(.trailing, 8)
                }
                .frame(maxHeight: 300)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

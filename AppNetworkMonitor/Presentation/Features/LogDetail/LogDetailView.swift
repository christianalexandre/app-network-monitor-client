//
//  LogDetailView.swift
//  AppNetworkMonitor
//
//  Created by Christian Alexandre on 17/12/25.
//

import SwiftUI

struct LogDetailView: View {
    let log: LogModel
    @State private var selectedTab: DetailTab = .summary
    
    enum DetailTab: String, CaseIterable {
        case summary = "Summary"
        case request = "Request"
        case response = "Response"
        case headers = "Headers"
        case metrics = "Metrics"
        case curl = "cURL"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Divider()
            
            Picker("", selection: $selectedTab) {
                ForEach(DetailTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    contentView
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(NSColor.textBackgroundColor))
        }
    }
    
    // MARK: - Subviews

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(log.method)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
                
                Text(log.path)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.medium)
                
                Spacer()
                
                // Status Badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(log.isError ? Color.red : Color.green)
                        .frame(width: 8, height: 8)
                    Text("\(log.statusCode)")
                        .font(.headline)
                        .monospacedDigit()
                }
                .padding(6)
                .background(log.isError ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                .cornerRadius(6)
            }

            Text(log.url)
                .font(.caption)
                .foregroundColor(.secondary)
                .textSelection(.enabled)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch selectedTab {
        case .summary:
            SummaryTab(log: log)
        case .request:
            JsonViewer(title: "Request Body", content: log.requestBody)
        case .response:
            JsonViewer(title: "Response Body", content: log.responseBody)
        case .headers:
            HeadersTab(reqHeaders: log.requestHeaders, resHeaders: log.responseHeaders)
        case .metrics:
            MetricsTab(log: log)
        case .curl:
            CurlTab(log: log)
        }
    }
}

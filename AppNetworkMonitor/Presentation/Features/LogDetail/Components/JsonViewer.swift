//
//  JsonViewer.swift
//  AppNetworkMonitor
//
//  Created by Christian Alexandre on 30/12/25.
//

import SwiftUI

struct JsonViewer: View {
    let title: String
    let content: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                if let content = content, !content.isEmpty {
                    Button(action: {
                        let pretty = content.prettyPrintedJSON ?? content
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(pretty, forType: .string)
                    }) {
                        Label("Copy JSON", systemImage: "doc.on.doc")
                    }
                    .font(.caption)
                }
            }
            
            if let content = content, !content.isEmpty {
                ScrollView(.horizontal, showsIndicators: true) {
                    Text(content.prettyPrintedJSON ?? content)
                        .font(.system(size: 12, design: .monospaced))
                        .padding()
                        .foregroundColor(Color(nsColor: .textColor))
                        .textSelection(.enabled)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            } else {
                Text("Empty Body")
                    .italic()
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
            }
        }
    }
}

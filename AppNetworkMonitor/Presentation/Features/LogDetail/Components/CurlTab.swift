//
//  CurlTab.swift
//  AppNetworkMonitor
//
//  Created by Christian Alexandre on 30/12/25.
//

import SwiftUI

struct CurlTab: View {
    let log: LogModel
    
    var body: some View {
        let curlCommand = CurlGenerator.generate(from: log)
        
        VStack(alignment: .leading) {
            HStack {
                Text("cURL Command").font(.headline)
                Spacer()
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(curlCommand, forType: .string)
                }) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
            .padding(.bottom, 8)
            
            Text(curlCommand)
                .font(.system(size: 12, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black)
                .foregroundColor(.green)
                .cornerRadius(8)
                .textSelection(.enabled)
        }
    }
}

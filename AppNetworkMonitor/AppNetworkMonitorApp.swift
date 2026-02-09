//
//  AppNetworkMonitorApp.swift
//  AppNetworkMonitor
//
//  Created by Christian Alexandre on 17/12/25.
//

import SwiftUI

@main
struct AppNetworkMonitorApp: App {
    @StateObject private var updateChecker = UpdateChecker()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .withUpdateAlert(checker: updateChecker)
                .task {
                    await updateChecker.checkOnLaunchIfNeeded()
                }
        }
        .commands {
            UpdateMenuCommands(updateChecker: updateChecker)
        }
    }
}

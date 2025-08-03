//
//  Lender_s_LedgerApp.swift
//  Lender-s-Ledger
//
//  Created by user12 on 2025/7/29.
//

import SwiftUI

@main
struct Lender_s_LedgerApp: App {
    @StateObject private var viewModel = LedgerViewModel()
    @StateObject private var calendarManager = CalendarManager()
    @StateObject private var appStateManager = AppStateManager()
    @State private var selectedTab = 0
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                ContentView()
                    .environmentObject(viewModel)
                    .environmentObject(calendarManager)
                    .environmentObject(appStateManager)
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Ledger")
                    }
                    .tag(0)
                
                DashboardView(viewModel: viewModel)
                    .environmentObject(appStateManager)
                    .tabItem {
                        Image(systemName: "chart.pie")
                        Text("Dashboard")
                    }
                    .tag(1)
                
                WishlistView(viewModel: viewModel)
                    .tabItem {
                        Image(systemName: "heart")
                        Text("Wishlist")
                    }
                    .tag(2)
            }
            .onChange(of: appStateManager.shouldNavigateToLedger) { _, shouldNavigate in
                if shouldNavigate {
                    selectedTab = 0
                    appStateManager.shouldNavigateToLedger = false
                }
            }
        }
    }
}

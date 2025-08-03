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
    @StateObject private var cloudKitManager = CloudKitManager()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .environmentObject(viewModel)
                    .environmentObject(calendarManager)
                    .environmentObject(cloudKitManager)
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Ledger")
                    }
                
                DashboardView(viewModel: viewModel)
                    .tabItem {
                        Image(systemName: "chart.pie")
                        Text("Dashboard")
                    }
                
                WishlistView(viewModel: viewModel)
                    .tabItem {
                        Image(systemName: "heart")
                        Text("Wishlist")
                    }
            }
        }
    }
}

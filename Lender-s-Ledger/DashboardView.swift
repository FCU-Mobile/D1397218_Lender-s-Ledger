//
//  DashboardView.swift
//  Lender-s-Ledger
//
//  Created by Advanced Features Implementation
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: LedgerViewModel
    @EnvironmentObject var appStateManager: AppStateManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Statistics Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        Button {
                            appStateManager.filterByType(.lent)
                        } label: {
                            StatCard(
                                title: "Items Lent",
                                value: "\(viewModel.totalLentItems)",
                                icon: "arrow.up.circle.fill",
                                color: .blue
                            )
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            appStateManager.filterByType(.borrowed)
                        } label: {
                            StatCard(
                                title: "Items Borrowed",
                                value: "\(viewModel.totalBorrowedItems)",
                                icon: "arrow.down.circle.fill",
                                color: .green
                            )
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            appStateManager.filterByStatus(.overdue)
                        } label: {
                            StatCard(
                                title: "Overdue Items",
                                value: "\(viewModel.totalOverdueItems)",
                                icon: "exclamationmark.triangle.fill",
                                color: .red
                            )
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            appStateManager.filterByStatus(.all)
                        } label: {
                            StatCard(
                                title: "Total Active",
                                value: "\(viewModel.totalLentItems + viewModel.totalBorrowedItems)",
                                icon: "list.bullet.circle.fill",
                                color: .purple
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if viewModel.items.filter({ !$0.isArchived }).isEmpty {
                            VStack {
                                Image(systemName: "tray")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text("No recent activity")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(Array(viewModel.items.filter({ !$0.isArchived }).prefix(5))) { item in
                                DashboardItemRow(item: item)
                            }
                        }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Popular Tags
                    if !viewModel.allActiveTags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Popular Tags")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 80))
                            ], spacing: 8) {
                                ForEach(Array(viewModel.allActiveTags.prefix(10)), id: \.self) { tag in
                                    Button {
                                        appStateManager.filterByTag(tag)
                                    } label: {
                                        Text(tag)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(16)
                                            .font(.caption)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct DashboardItemRow: View {
    let item: LedgerItem
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(item.type == .lent ? .blue : .green)
                .frame(width: 4, height: 30)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(item.type == .lent ? "To: \(item.person)" : "From: \(item.person)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if item.isOverdue {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Text(item.formattedDate)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    DashboardView(viewModel: LedgerViewModel())
}
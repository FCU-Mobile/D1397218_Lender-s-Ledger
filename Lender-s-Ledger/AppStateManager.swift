//
//  AppStateManager.swift
//  Lender-s-Ledger
//
//  Created by Cross-View Filtering Feature
//

import SwiftUI

class AppStateManager: ObservableObject {
    @Published var activeTagFilter: String? = nil
    @Published var activeTypeFilter: ItemType? = nil
    @Published var activeStatusFilter: StatusFilter? = nil
    @Published var shouldNavigateToLedger: Bool = false
    
    enum StatusFilter: String, CaseIterable {
        case overdue = "Overdue"
        case all = "All Active"
    }
    
    // Function to clear all filters
    func clearFilters() {
        activeTagFilter = nil
        activeTypeFilter = nil
        activeStatusFilter = nil
    }
    
    // Function to set tag filter and navigate to ledger
    func filterByTag(_ tag: String) {
        clearFilters()
        activeTagFilter = tag
        shouldNavigateToLedger = true
    }
    
    // Function to set type filter and navigate to ledger
    func filterByType(_ type: ItemType) {
        clearFilters()
        activeTypeFilter = type
        shouldNavigateToLedger = true
    }
    
    // Function to set status filter and navigate to ledger
    func filterByStatus(_ status: StatusFilter) {
        clearFilters()
        activeStatusFilter = status
        shouldNavigateToLedger = true
    }
    
    // Check if any filter is active
    var hasActiveFilter: Bool {
        return activeTagFilter != nil || activeTypeFilter != nil || activeStatusFilter != nil
    }
    
    // Get filter description for UI
    var filterDescription: String {
        if let tag = activeTagFilter {
            return "Tag: \(tag)"
        } else if let type = activeTypeFilter {
            return "Type: \(type.rawValue)"
        } else if let status = activeStatusFilter {
            return "Status: \(status.rawValue)"
        }
        return ""
    }
}
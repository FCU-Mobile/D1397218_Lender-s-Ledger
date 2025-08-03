//
//  LedgerIntents.swift
//  Lender-s-Ledger
//
//  Created by Advanced Features Implementation
//

import Foundation
import AppIntents

@available(iOS 16.0, *)
struct FindLentItemsIntent: AppIntent {
    static var title: LocalizedStringResource = "Find My Lent Items"
    static var description = IntentDescription("Find out who has your lent items")
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // In a real app, this would access the shared data store
        // For now, we'll simulate the response
        let sampleItems = [
            "The Hobbit by J.R.R. Tolkien - lent to Alex (overdue)",
            "Portable Charger - lent to Brenda (due in 3 days)",
            "HDMI Cable - lent to Diana"
        ]
        
        let response: String
        if sampleItems.isEmpty {
            response = "You don't have any items currently lent out. Great job keeping track of your stuff!"
        } else {
            response = "Here are your currently lent items:\n\n" + sampleItems.joined(separator: "\n")
        }
        
        return .result(dialog: IntentDialog(stringLiteral: response))
    }
}

@available(iOS 16.0, *)
struct LedgerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FindLentItemsIntent(),
            phrases: [
                "Who has my stuff in \(.applicationName)?",
                "What did I lend out in \(.applicationName)?",
                "Show my lent items in \(.applicationName)",
                "Find my lent items"
            ],
            shortTitle: "Find Lent Items",
            systemImageName: "list.bullet"
        )
    }
}

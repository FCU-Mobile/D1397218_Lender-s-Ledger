//
//  CalendarManager.swift
//  Lender-s-Ledger
//
//  Created by Advanced Features Implementation
//

import Foundation
import EventKit

class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    func requestCalendarAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestWriteOnlyAccessToEvents()
            await MainActor.run {
                self.authorizationStatus = granted ? .fullAccess : .denied
            }
            return granted
        } catch {
            print("Calendar access request failed: \(error)")
            await MainActor.run {
                self.authorizationStatus = .denied
            }
            return false
        }
    }
    
    func addReturnReminder(for item: LedgerItem) async -> Bool {
        guard let returnDate = item.returnByDate else { return false }
        
        // Request access if needed
        if authorizationStatus != .fullAccess {
            let granted = await requestCalendarAccess()
            if !granted { return false }
        }
        
        // Create the event
        let event = EKEvent(eventStore: eventStore)
        event.title = "Return: \(item.name)"
        event.notes = "Return \(item.name) to \(item.person)"
        event.startDate = Calendar.current.startOfDay(for: returnDate)
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: event.startDate) ?? event.startDate
        event.isAllDay = false
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // Add reminder 1 day before
        let reminder = EKAlarm(relativeOffset: -86400) // 24 hours before
        event.addAlarm(reminder)
        
        do {
            try eventStore.save(event, span: .thisEvent)
            return true
        } catch {
            print("Failed to save calendar event: \(error)")
            return false
        }
    }
    
    func createCalendarEvent(title: String, date: Date, notes: String? = nil) async -> Bool {
        if authorizationStatus != .fullAccess {
            let granted = await requestCalendarAccess()
            if !granted { return false }
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.notes = notes
        event.startDate = date
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: date) ?? date
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            return true
        } catch {
            print("Failed to save calendar event: \(error)")
            return false
        }
    }
}
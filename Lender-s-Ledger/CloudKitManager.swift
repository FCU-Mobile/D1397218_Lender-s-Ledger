//
//  CloudKitManager.swift
//  Lender-s-Ledger
//
//  Created by Advanced Features Implementation
//

import Foundation
import CloudKit
import UIKit

class CloudKitManager: ObservableObject {
    private let container: CKContainer
    private let database: CKDatabase
    
    @Published var isSignedInToiCloud = false
    @Published var error: String?
    
    init() {
        container = CKContainer.default()
        database = container.privateCloudDatabase
        checkiCloudStatus()
    }
    
    func checkiCloudStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.error = error.localizedDescription
                    self?.isSignedInToiCloud = false
                } else {
                    self?.isSignedInToiCloud = (status == .available)
                }
            }
        }
    }
    
    // MARK: - Ledger Items
    
    func saveLedgerItem(_ item: LedgerItem) async throws {
        let record = CKRecord(recordType: "LedgerItem")
        record["name"] = item.name
        record["person"] = item.person
        record["type"] = item.type.rawValue
        record["date"] = item.date
        record["returnByDate"] = item.returnByDate
        record["isArchived"] = item.isArchived
        record["conditionNotes"] = item.conditionNotes
        record["tags"] = item.tags
        
        if let imageData = item.imageData {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try imageData.write(to: tempURL)
            record["imageData"] = CKAsset(fileURL: tempURL)
        }
        
        do {
            _ = try await database.save(record)
        } catch {
            throw error
        }
    }
    
    func fetchLedgerItems() async throws -> [LedgerItem] {
        let query = CKQuery(recordType: "LedgerItem", predicate: NSPredicate(value: true))
        let result = try await database.records(matching: query)
        
        var items: [LedgerItem] = []
        for (_, recordResult) in result.matchResults {
            switch recordResult {
            case .success(let record):
                if let item = ledgerItemFromRecord(record) {
                    items.append(item)
                }
            case .failure(let error):
                print("Failed to fetch record: \(error)")
            }
        }
        
        return items
    }
    
    // MARK: - Wishlist Items
    
    func saveWishlistItem(_ item: WishlistItem) async throws {
        let record = CKRecord(recordType: "WishlistItem")
        record["name"] = item.name
        record["itemDescription"] = item.description
        record["estimatedPrice"] = item.estimatedPrice
        record["priority"] = item.priority.rawValue
        record["dateAdded"] = item.dateAdded
        record["tags"] = item.tags
        
        do {
            _ = try await database.save(record)
        } catch {
            throw error
        }
    }
    
    func fetchWishlistItems() async throws -> [WishlistItem] {
        let query = CKQuery(recordType: "WishlistItem", predicate: NSPredicate(value: true))
        let result = try await database.records(matching: query)
        
        var items: [WishlistItem] = []
        for (_, recordResult) in result.matchResults {
            switch recordResult {
            case .success(let record):
                if let item = wishlistItemFromRecord(record) {
                    items.append(item)
                }
            case .failure(let error):
                print("Failed to fetch wishlist record: \(error)")
            }
        }
        
        return items
    }
    
    // MARK: - Sharing
    
    func shareItems(_ items: [LedgerItem]) async throws -> CKShare {
        // Create a new record zone for sharing
        let zoneID = CKRecordZone.ID(zoneName: "SharedLedger")
        let zone = CKRecordZone(zoneID: zoneID)
        
        // Save the zone first
        _ = try await database.save(zone)
        
        // Create records for sharing
        var recordsToShare: [CKRecord] = []
        for item in items {
            let record = CKRecord(recordType: "LedgerItem", zoneID: zoneID)
            record["name"] = item.name
            record["person"] = item.person
            record["type"] = item.type.rawValue
            record["date"] = item.date
            recordsToShare.append(record)
        }
        
        // Save records
        _ = try await database.modifyRecords(saving: recordsToShare, deleting: [])
        
        // Create share
        let share = CKShare(rootRecord: recordsToShare.first!)
        share[CKShare.SystemFieldKey.title] = "Shared Ledger Items"
        
        _ = try await database.save(share)
        return share
    }
    
    // MARK: - Helper Methods
    
    private func ledgerItemFromRecord(_ record: CKRecord) -> LedgerItem? {
        guard let name = record["name"] as? String,
              let person = record["person"] as? String,
              let typeRaw = record["type"] as? String,
              let type = ItemType(rawValue: typeRaw),
              let date = record["date"] as? Date else {
            return nil
        }
        
        let returnByDate = record["returnByDate"] as? Date
        let isArchived = record["isArchived"] as? Bool ?? false
        let conditionNotes = record["conditionNotes"] as? String
        let tags = record["tags"] as? [String] ?? []
        
        var imageData: Data?
        if let asset = record["imageData"] as? CKAsset,
           let fileURL = asset.fileURL {
            imageData = try? Data(contentsOf: fileURL)
        }
        
        return LedgerItem(
            name: name,
            person: person,
            type: type,
            date: date,
            returnByDate: returnByDate,
            isArchived: isArchived,
            conditionNotes: conditionNotes,
            imageData: imageData,
            tags: tags
        )
    }
    
    private func wishlistItemFromRecord(_ record: CKRecord) -> WishlistItem? {
        guard let name = record["name"] as? String else { return nil }
        
        let description = record["itemDescription"] as? String
        let estimatedPrice = record["estimatedPrice"] as? Double
        let priorityRaw = record["priority"] as? String ?? "Medium"
        let priority = WishlistPriority(rawValue: priorityRaw) ?? .medium
        let dateAdded = record["dateAdded"] as? Date ?? Date()
        let tags = record["tags"] as? [String] ?? []
        
        return WishlistItem(
            name: name,
            description: description,
            estimatedPrice: estimatedPrice,
            priority: priority,
            dateAdded: dateAdded,
            tags: tags
        )
    }
}
//
//  Lender_s_LedgerTests.swift
//  Lender-s-LedgerTests
//
//  Created by user12 on 2025/7/29.
//

import Testing
@testable import Lender_s_Ledger

struct Lender_s_LedgerTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test func testLedgerItemImageData() async throws {
        // Test that LedgerItem can store image data
        let sampleImageData = Data([0x89, 0x50, 0x4E, 0x47]) // PNG header bytes
        let item = LedgerItem(
            name: "Test Item",
            person: "Test Person", 
            type: .lent,
            date: Date(),
            imageData: sampleImageData
        )
        
        #expect(item.imageData != nil)
        #expect(item.imageData == sampleImageData)
        #expect(item.name == "Test Item")
        #expect(item.person == "Test Person")
        #expect(item.type == .lent)
    }
    
    @Test func testLedgerViewModelAddItemWithImage() async throws {
        // Test that view model can add items with image data
        let viewModel = LedgerViewModel()
        let initialCount = viewModel.items.count
        let sampleImageData = Data([0x89, 0x50, 0x4E, 0x47])
        
        viewModel.addItem(
            name: "Camera Test Item",
            person: "Test User",
            type: .borrowed,
            imageData: sampleImageData
        )
        
        #expect(viewModel.items.count == initialCount + 1)
        let addedItem = viewModel.items.first
        #expect(addedItem?.name == "Camera Test Item")
        #expect(addedItem?.imageData == sampleImageData)
        #expect(addedItem?.type == .borrowed)
    }

}

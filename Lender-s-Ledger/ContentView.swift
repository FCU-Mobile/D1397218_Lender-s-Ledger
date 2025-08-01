//
//  ContentView.swift
//  Lender-s-Ledger
//
//  Created by user12 on 2025/7/29.
//

import SwiftUI

// --- DATA MODEL ---
// In Xcode, you would put this in its own file: `LedgerItem.swift`

// An enum to define the type of transaction. Using an enum is safer than a plain string.
enum ItemType: String, CaseIterable, Codable {
    case lent = "Lent"
    case borrowed = "Borrowed"
}

// This struct represents a single item in our ledger.
// `Identifiable` is needed to use this object in a List.
// `Codable` allows us to easily save/load this data in the future.
struct LedgerItem: Identifiable, Codable {
    var id = UUID() // Unique identifier for each item
    var name: String
    var person: String
    var type: ItemType
    var date: Date
    
    // A computed property to format the date nicely.
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}


// --- VIEW MODEL ---
// In Xcode, you would put this in its own file: `LedgerViewModel.swift`

// This class holds and manages all the app's data and logic.
// It's an `ObservableObject` so that our views can watch it for changes.
class LedgerViewModel: ObservableObject {
    
    // `@Published` tells SwiftUI to update any view using this property whenever it changes.
    @Published var items: [LedgerItem] = [] {
        // This `didSet` block is a good place to add code to save data later.
        didSet {
            print("Items updated!")
        }
    }
    
    // Computed properties to easily get filtered lists.
    var lentItems: [LedgerItem] {
        items.filter { $0.type == .lent }
    }
    
    var borrowedItems: [LedgerItem] {
        items.filter { $0.type == .borrowed }
    }
    
    init() {
        // Load some sample data when the app starts.
        loadSampleData()
    }
    
    // Function to add a new item.
    func addItem(name: String, person: String, type: ItemType) {
        let newItem = LedgerItem(name: name, person: person, type: type, date: Date())
        items.insert(newItem, at: 0) // Add to the top of the list
    }
    
    // Function to remove an item.
    func deleteItem(at offsets: IndexSet, from section: ItemType) {
        // This logic correctly identifies which item to delete from the main `items` array.
        let idsToDelete = offsets.map { (section == .lent ? lentItems : borrowedItems)[$0].id }
        items.removeAll { idsToDelete.contains($0.id) }
    }
    
    func loadSampleData() {
        self.items = [
            LedgerItem(name: "The Hobbit by J.R.R. Tolkien", person: "Alex", type: .lent, date: Date().addingTimeInterval(-86400 * 5)),
            LedgerItem(name: "Portable Charger", person: "Brenda", type: .lent, date: Date().addingTimeInterval(-86400 * 2)),
            LedgerItem(name: "Ladder", person: "Carlos", type: .borrowed, date: Date().addingTimeInterval(-86400 * 1)),
            LedgerItem(name: "HDMI Cable", person: "Diana", type: .lent, date: Date())
        ]
    }
}


// --- VIEWS ---

// In Xcode, you would put this in its own file: `AddItemView.swift`
struct AddItemView: View {
    // `@Environment` allows us to dismiss this view when we're done.
    @Environment(\.dismiss) var dismiss
    
    // `@ObservedObject` lets us use the view model that was passed from the parent view.
    @ObservedObject var viewModel: LedgerViewModel
    
    // `@State` is used for simple view-specific properties that can change.
    @State private var itemName = ""
    @State private var personName = ""
    @State private var itemType: ItemType = .lent
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name (e.g., 'Dune' Book)", text: $itemName)
                    TextField("Person's Name", text: $personName)
                }
                
                Section {
                    // A picker to select whether the item was lent or borrowed.
                    Picker("Type", selection: $itemType) {
                        ForEach(ItemType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Button("Add Item") {
                        // Basic validation
                        if !itemName.isEmpty && !personName.isEmpty {
                            viewModel.addItem(name: itemName, person: personName, type: itemType)
                            dismiss() // Close the sheet
                        }
                    }
                    .disabled(itemName.isEmpty || personName.isEmpty)
                }
            }
            .navigationTitle("Add to Ledger")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }
}


// In Xcode, you would put this in its own file: `LedgerRowView.swift`
struct LedgerRowView: View {
    let item: LedgerItem
    
    var body: some View {
        HStack {
            // A colored bar to indicate the item type.
            Rectangle()
                .fill(item.type == .lent ? .blue : .green)
                .frame(width: 4, height: 40)
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.headline)
                
                Text(item.type == .lent ? "To: \(item.person)" : "From: \(item.person)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(item.formattedDate)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}


// In Xcode, this would be your main view file: `ContentView.swift`
struct ContentView: View {
    // `@StateObject` creates and owns the instance of our view model.
    // This object will stay alive for the entire lifecycle of the view.
    @StateObject private var viewModel = LedgerViewModel()
    
    // `@State` to control whether the "Add Item" sheet is showing.
    @State private var isShowingAddItemView = false
    
    var body: some View {
        NavigationView {
            List {
                // --- LENT SECTION ---
                Section(header: Text("I Lent (\(viewModel.lentItems.count))")) {
                    if viewModel.lentItems.isEmpty {
                        Text("You haven't lent any items yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.lentItems) { item in
                            LedgerRowView(item: item)
                        }
                        // This modifier enables the "swipe to delete" gesture.
                        .onDelete { offsets in
                            viewModel.deleteItem(at: offsets, from: .lent)
                        }
                    }
                }
                
                // --- BORROWED SECTION ---
                Section(header: Text("I Borrowed (\(viewModel.borrowedItems.count))")) {
                    if viewModel.borrowedItems.isEmpty {
                        Text("You haven't borrowed any items.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.borrowedItems) { item in
                            LedgerRowView(item: item)
                        }
                        .onDelete { offsets in
                            viewModel.deleteItem(at: offsets, from: .borrowed)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped) // A modern iOS list style.
            .navigationTitle("Lender's Ledger")
            .toolbar {
                // The "+" button in the top-right corner.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingAddItemView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // This presents the `AddItemView` as a sheet when `isShowingAddItemView` is true.
            .sheet(isPresented: $isShowingAddItemView) {
                AddItemView(viewModel: viewModel)
            }
        }
    }
}


// --- PREVIEW ---
// This is just for Xcode's preview canvas, so you can see your UI without running the app.
#Preview {
    ContentView()
}

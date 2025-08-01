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
    var returnByDate: Date? // New property to indicate when the item should be returned
    var isArchived: Bool = false // New property to mark an item as archived
    var conditionNotes: String? // New property for any condition notes
    var imageData: Data? // New property to store image data
    
    // A computed property to format the date nicely.
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // Computed property to check if the item is overdue
    var isOverdue: Bool {
        if let returnByDate = returnByDate {
            return Date() > returnByDate && !isArchived
        }
        return false
    }
    
    // Computed property to format the return date
    var formattedReturnDate: String? {
        if let returnByDate = returnByDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: returnByDate)
        }
        return nil
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
    
    // Computed properties to easily get filtered lists (excluding archived items).
    var lentItems: [LedgerItem] {
        items.filter { $0.type == .lent && !$0.isArchived }
    }
    
    var borrowedItems: [LedgerItem] {
        items.filter { $0.type == .borrowed && !$0.isArchived }
    }
    
    // Computed property for archived items
    var archivedItems: [LedgerItem] {
        items.filter { $0.isArchived }
    }
    
    // Function to filter items based on search text
    func filteredLentItems(searchText: String) -> [LedgerItem] {
        if searchText.isEmpty {
            return lentItems
        } else {
            return lentItems.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.person.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func filteredBorrowedItems(searchText: String) -> [LedgerItem] {
        if searchText.isEmpty {
            return borrowedItems
        } else {
            return borrowedItems.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.person.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    init() {
        // Load some sample data when the app starts.
        loadSampleData()
    }
    
    // Enhanced function to add a new item with all new properties.
    func addItem(name: String, person: String, type: ItemType, returnByDate: Date? = nil, conditionNotes: String? = nil, imageData: Data? = nil) {
        let newItem = LedgerItem(
            name: name,
            person: person,
            type: type,
            date: Date(),
            returnByDate: returnByDate,
            conditionNotes: conditionNotes,
            imageData: imageData
        )
        items.insert(newItem, at: 0) // Add to the top of the list
    }
    
    // Function to archive an item instead of deleting it.
    func archiveItem(at offsets: IndexSet, from section: ItemType) {
        let idsToArchive = offsets.map { (section == .lent ? lentItems : borrowedItems)[$0].id }
        for i in items.indices {
            if idsToArchive.contains(items[i].id) {
                items[i].isArchived = true
            }
        }
    }
    
    // Function to permanently delete archived items
    func deleteArchivedItem(at offsets: IndexSet) {
        let idsToDelete = offsets.map { archivedItems[$0].id }
        items.removeAll { idsToDelete.contains($0.id) }
    }
    
    func loadSampleData() {
        let calendar = Calendar.current
        let today = Date()
        
        self.items = [
            LedgerItem(
                name: "The Hobbit by J.R.R. Tolkien",
                person: "Alex",
                type: .lent,
                date: Date().addingTimeInterval(-86400 * 5),
                returnByDate: calendar.date(byAdding: .day, value: -2, to: today), // Overdue
                conditionNotes: "Good condition, paperback"
            ),
            LedgerItem(
                name: "Portable Charger",
                person: "Brenda",
                type: .lent,
                date: Date().addingTimeInterval(-86400 * 2),
                returnByDate: calendar.date(byAdding: .day, value: 3, to: today)
            ),
            LedgerItem(
                name: "Ladder",
                person: "Carlos",
                type: .borrowed,
                date: Date().addingTimeInterval(-86400 * 1),
                returnByDate: calendar.date(byAdding: .day, value: 5, to: today),
                conditionNotes: "Excellent condition, aluminum"
            ),
            LedgerItem(
                name: "HDMI Cable",
                person: "Diana",
                type: .lent,
                date: Date()
            )
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
    @State private var returnByDate = Date()
    @State private var conditionNotes = ""
    @State private var imageData: Data? = nil
    
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
                
                Section(header: Text("Additional Details")) {
                    DatePicker("Return By", selection: $returnByDate, displayedComponents: .date)
                    TextField("Condition Notes", text: $conditionNotes)
                }
                
                Section {
                    Button("Add Item") {
                        // Basic validation
                        if !itemName.isEmpty && !personName.isEmpty {
                            viewModel.addItem(
                                name: itemName,
                                person: personName,
                                type: itemType,
                                returnByDate: returnByDate,
                                conditionNotes: conditionNotes,
                                imageData: imageData
                            )
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
    
    // `@State` for search text
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                // --- LENT SECTION ---
                Section {
                    if viewModel.lentItems.isEmpty {
                        Text("You haven't lent any items yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.filteredLentItems(searchText: searchText)) { item in
                            LedgerRowView(item: item)
                        }
                        // This modifier enables the "swipe to archive" gesture.
                        .onDelete { offsets in
                            viewModel.archiveItem(at: offsets, from: .lent)
                        }
                    }
                } header: {
                    Text("I Lent (\(viewModel.lentItems.count))")
                }
                
                // --- BORROWED SECTION ---
                Section {
                    if viewModel.borrowedItems.isEmpty {
                        Text("You haven't borrowed any items.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.filteredBorrowedItems(searchText: searchText)) { item in
                            LedgerRowView(item: item)
                        }
                        .onDelete { offsets in
                            viewModel.archiveItem(at: offsets, from: .borrowed)
                        }
                    }
                } header: {
                    Text("I Borrowed (\(viewModel.borrowedItems.count))")
                }
                
                // --- ARCHIVED ITEMS SECTION ---
                Section {
                    if viewModel.archivedItems.isEmpty {
                        Text("No archived items.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.archivedItems) { item in
                            LedgerRowView(item: item)
                        }
                        .onDelete { offsets in
                            viewModel.deleteArchivedItem(at: offsets)
                        }
                    }
                } header: {
                    Text("Archived Items (\(viewModel.archivedItems.count))")
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
            .searchable(text: $searchText, prompt: "Search items or people")
        }
    }
}


// In Xcode, you would put this in its own file: `ArchiveView.swift`
struct ArchiveView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: LedgerViewModel
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.archivedItems.isEmpty {
                    Text("No archived items.")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .padding()
                } else {
                    ForEach(viewModel.archivedItems) { item in
                        NavigationLink(destination: LedgerDetailView(item: item)) {
                            LedgerRowView(item: item)
                        }
                    }
                    .onDelete { offsets in
                        viewModel.deleteArchivedItem(at: offsets)
                    }
                }
            }
            .navigationTitle("Archive History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                if !viewModel.archivedItems.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
        }
    }
}


// In Xcode, you would put this in its own file: `LedgerDetailView.swift`
struct LedgerDetailView: View {
    let item: LedgerItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(item.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(item.isOverdue ? .red : .primary)
                        
                        Spacer()
                        
                        if item.isOverdue {
                            Label("Overdue", systemImage: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.headline)
                        }
                    }
                    
                    Text(item.type == .lent ? "Lent to: \(item.person)" : "Borrowed from: \(item.person)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Date Information
                VStack(alignment: .leading, spacing: 12) {
                    Label {
                        Text(item.formattedDate)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                    }
                    
                    if let returnDate = item.formattedReturnDate {
                        Label {
                            Text(returnDate)
                                .foregroundColor(item.isOverdue ? .red : .secondary)
                        } icon: {
                            Image(systemName: "clock")
                                .foregroundColor(item.isOverdue ? .red : .orange)
                        }
                    }
                }
                
                // Condition Notes
                if let conditionNotes = item.conditionNotes {
                    Divider()
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("Condition Notes")
                                .font(.headline)
                        } icon: {
                            Image(systemName: "note.text")
                                .foregroundColor(.green)
                        }
                        
                        Text(conditionNotes)
                            .foregroundColor(.secondary)
                            .padding(.leading, 28)
                    }
                }
                
                // Photo Display
                if let imageData = item.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Divider()
                    VStack(alignment: .leading, spacing: 12) {
                        Label {
                            Text("Photo")
                                .font(.headline)
                        } icon: {
                            Image(systemName: "camera")
                                .foregroundColor(.purple)
                        }
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    }
                }
                
                // Archive Status
                if item.isArchived {
                    Divider()
                    Label {
                        Text("This item has been archived")
                            .foregroundColor(.orange)
                    } icon: {
                        Image(systemName: "archivebox.fill")
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// --- PREVIEW ---
// This is just for Xcode's preview canvas, so you can see your UI without running the app.
#Preview {
    ContentView()
}

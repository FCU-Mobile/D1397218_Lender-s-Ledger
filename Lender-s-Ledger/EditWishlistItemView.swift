//
//  EditWishlistItemView.swift
//  Lender-s-Ledger
//
//  Created by Editable Wishlist Feature
//

import SwiftUI

struct EditWishlistItemView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: LedgerViewModel
    
    let itemId: UUID
    @State private var itemName: String
    @State private var itemDescription: String
    @State private var estimatedPrice: String
    @State private var priority: WishlistPriority
    @State private var currentTag = ""
    @State private var tags: [String]
    
    init(item: WishlistItem, viewModel: LedgerViewModel) {
        self.itemId = item.id
        self.viewModel = viewModel
        self._itemName = State(initialValue: item.name)
        self._itemDescription = State(initialValue: item.description ?? "")
        self._estimatedPrice = State(initialValue: {
            if let price = item.estimatedPrice {
                return String(format: "%.2f", price)
            }
            return ""
        }())
        self._priority = State(initialValue: item.priority)
        self._tags = State(initialValue: item.tags)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name", text: $itemName)
                    TextField("Description (optional)", text: $itemDescription, axis: .vertical)
                        .lineLimit(3)
                }
                
                Section(header: Text("Priority & Price")) {
                    Picker("Priority", selection: $priority) {
                        ForEach(WishlistPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("Estimated Price (optional)", text: $estimatedPrice)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Tags")) {
                    HStack {
                        TextField("Add tag", text: $currentTag)
                            .onSubmit {
                                addTag()
                            }
                        
                        Button("Add") {
                            addTag()
                        }
                        .disabled(currentTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    HStack(spacing: 4) {
                                        Text(tag)
                                        Button {
                                            removeTag(tag)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.purple.opacity(0.1))
                                    .foregroundColor(.purple)
                                    .cornerRadius(12)
                                    .font(.caption)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button("Save Changes") {
                        saveChanges()
                        dismiss()
                    }
                    .disabled(itemName.isEmpty)
                }
            }
            .navigationTitle("Edit Wishlist Item")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addTag() {
        let trimmedTag = currentTag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            currentTag = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func saveChanges() {
        let price = Double(estimatedPrice.trimmingCharacters(in: .whitespacesAndNewlines))
        let description = itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        viewModel.updateWishlistItem(
            id: itemId,
            name: itemName,
            description: description.isEmpty ? nil : description,
            estimatedPrice: price,
            priority: priority,
            tags: tags
        )
    }
}

#Preview {
    EditWishlistItemView(
        item: WishlistItem(
            name: "Sample Item",
            description: "Sample description",
            estimatedPrice: 99.99,
            priority: .high,
            tags: ["tag1", "tag2"]
        ),
        viewModel: LedgerViewModel()
    )
}
//
//  WishlistView.swift
//  Lender-s-Ledger
//
//  Created by Advanced Features Implementation
//

import SwiftUI

struct WishlistView: View {
    @ObservedObject var viewModel: LedgerViewModel
    @State private var isShowingAddWishlistView = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.wishlistItems.isEmpty {
                    VStack {
                        Image(systemName: "heart.circle")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No wishlist items yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Add items you'd like to own or borrow")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(viewModel.filteredWishlistItems(searchText: searchText)) { item in
                        WishlistItemRow(item: item)
                    }
                    .onDelete { offsets in
                        viewModel.deleteWishlistItem(at: offsets)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Wishlist")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingAddWishlistView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddWishlistView) {
                AddWishlistItemView(viewModel: viewModel)
            }
            .searchable(text: $searchText, prompt: "Search wishlist items")
        }
    }
}

struct WishlistItemRow: View {
    let item: WishlistItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                    
                    if let description = item.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    PriorityBadge(priority: item.priority)
                    
                    if let price = item.formattedPrice {
                        Text(price)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
            }
            
            if !item.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(item.tags, id: \.self) { tag in
                            Text(tag)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.purple.opacity(0.1))
                                .foregroundColor(.purple)
                                .cornerRadius(12)
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct PriorityBadge: View {
    let priority: WishlistPriority
    
    var body: some View {
        Text(priority.rawValue)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(priorityColor.opacity(0.2))
            .foregroundColor(priorityColor)
            .cornerRadius(8)
            .font(.caption)
            .fontWeight(.semibold)
    }
    
    private var priorityColor: Color {
        switch priority {
        case .low:
            return .gray
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}

struct AddWishlistItemView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: LedgerViewModel
    
    @State private var itemName = ""
    @State private var itemDescription = ""
    @State private var estimatedPrice = ""
    @State private var priority: WishlistPriority = .medium
    @State private var currentTag = ""
    @State private var tags: [String] = []
    
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
                    Button("Add to Wishlist") {
                        addWishlistItem()
                        dismiss()
                    }
                    .disabled(itemName.isEmpty)
                }
            }
            .navigationTitle("Add Wishlist Item")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
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
    
    private func addWishlistItem() {
        let price = Double(estimatedPrice.trimmingCharacters(in: .whitespacesAndNewlines))
        let description = itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        viewModel.addWishlistItem(
            name: itemName,
            description: description.isEmpty ? nil : description,
            estimatedPrice: price,
            priority: priority,
            tags: tags
        )
    }
}

#Preview {
    WishlistView(viewModel: LedgerViewModel())
}
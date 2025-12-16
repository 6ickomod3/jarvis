import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Bindable var trip: Trip
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PackingCategory.name) private var allCategories: [PackingCategory]
    
    @State private var showingItemSelector = false
    
    var progress: Double {
        guard !trip.items.isEmpty else { return 0 }
        let packedCount = trip.items.filter { $0.isPacked }.count
        return Double(packedCount) / Double(trip.items.count)
    }
    
    var body: some View {
        ZStack {
            Color.surfaceBackground.ignoresSafeArea() // Nordic Background
            
            List {
                // Header Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(trip.destination)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.primaryText)
                        
                        Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) - \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.body)
                            .foregroundStyle(Color.secondaryText)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Packing Progress")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.secondaryText)
                                Spacer()
                                Text("\(Int(progress * 100))%")
                                    .font(.caption)
                                    .foregroundStyle(Color.brandPrimary)
                            }
                            
                            ProgressView(value: progress)
                                .tint(Color.brandPrimary)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                    
                    Button(action: { showingItemSelector = true }) {
                        Label("Add Items from Pool", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundStyle(Color.brandPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                }
                .listRowBackground(Color.cardBackground)
                
                // Items by Category
                // Loop through global categories first to maintain order
                ForEach(allCategories) { category in
                    let items = trip.items.filter { $0.category == category.name }.sorted(by: { $0.orderIndex < $1.orderIndex })
                    
                    if !items.isEmpty {
                        Section(header: 
                            Text(category.name.uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.secondaryText)
                        ) {
                            ForEach(items) { item in
                                TripItemRow(item: item)
                            }
                            .onDelete { indexSet in
                                deleteItems(at: indexSet, from: items)
                            }
                            .onMove { indices, newOffset in
                                moveItems(from: indices, to: newOffset, in: items)
                            }
                        }
                        .listRowBackground(Color.cardBackground)
                    }
                }
                
                // "Other" Items
                let otherItems = trip.items.filter { item in
                    !allCategories.contains { $0.name == item.category }
                }.sorted(by: { $0.orderIndex < $1.orderIndex })
                
                if !otherItems.isEmpty {
                    Section(header: 
                        Text("OTHER")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.secondaryText)
                    ) {
                        ForEach(otherItems) { item in
                            TripItemRow(item: item)
                        }
                        .onDelete { indexSet in
                            deleteItems(at: indexSet, from: otherItems)
                        }
                        .onMove { indices, newOffset in
                            moveItems(from: indices, to: newOffset, in: otherItems)
                        }
                    }
                    .listRowBackground(Color.cardBackground)
                }
            }
            .scrollContentBackground(.hidden) // Remove default List gray background
        }
        .navigationTitle("Packing List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton() // Enables reordering
        }
        .sheet(isPresented: $showingItemSelector) {
            ItemSelectionView(trip: trip)
        }
    }
    
    private func deleteItems(at offsets: IndexSet, from items: [PackingItem]) {
        withAnimation {
            for index in offsets {
                if let itemIndex = trip.items.firstIndex(where: { $0.id == items[index].id }) {
                    let itemToDelete = trip.items[itemIndex]
                    trip.items.remove(at: itemIndex)
                    modelContext.delete(itemToDelete)
                }
            }
        }
    }
    
    private func moveItems(from source: IndexSet, to destination: Int, in items: [PackingItem]) {
        // Create a mutable copy of the section items for reordering
        var movingItems = items
        movingItems.move(fromOffsets: source, toOffset: destination)
        
        // Update orderIndex for ALL items in this category based on their new positions
        for (index, item) in movingItems.enumerated() {
            item.orderIndex = index
        }
        
        // Note: We don't need to re-sort trip.items because we are just updating indices.
        // The View re-renders based on the filter + sort query.
    }
}

struct TripItemRow: View {
    @Bindable var item: PackingItem
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(duration: 0.2)) {
                item.isPacked.toggle()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(item.isPacked ? Color.accentSuccess : Color.brandSecondary)
                
                Text(item.name)
                    .font(.body)
                    .strikethrough(item.isPacked)
                    .foregroundStyle(item.isPacked ? Color.secondaryText : Color.primaryText)
                
                Spacer()
            }
            .contentShape(Rectangle()) // Improves tap area
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
}

// Subview for selecting items from the pool
struct ItemSelectionView: View {
    var trip: Trip
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PackingCategory.name) private var categories: [PackingCategory]
    
    @State private var selectedItems: Set<UUID> = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.surfaceBackground.ignoresSafeArea()
                
                List {
                    // No Quick Add Section
                    
                    ForEach(categories) { category in
                        Section(header: Text(category.name.uppercased())) {
                            ForEach(category.items) { masterItem in
                                let isAlreadyInTrip = trip.items.contains { $0.name == masterItem.name && $0.category == category.name }
                                
                                HStack {
                                    Text(masterItem.name)
                                        .foregroundStyle(isAlreadyInTrip ? Color.secondaryText : Color.primaryText)
                                    Spacer()
                                    if isAlreadyInTrip {
                                        Image(systemName: "checkmark")
                                            .font(.caption)
                                            .foregroundStyle(Color.secondaryText)
                                    } else {
                                        Image(systemName: selectedItems.contains(masterItem.id) ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(selectedItems.contains(masterItem.id) ? Color.brandPrimary : Color.brandSecondary)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if !isAlreadyInTrip {
                                        if selectedItems.contains(masterItem.id) {
                                            selectedItems.remove(masterItem.id)
                                        } else {
                                            selectedItems.insert(masterItem.id)
                                        }
                                    }
                                }
                            }
                        }
                        .listRowBackground(Color.cardBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Items")
            .toolbar {

                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        NavigationLink(destination: ManagePoolView()) {
                             Image(systemName: "list.bullet.clipboard")
                                 .foregroundStyle(Color.brandPrimary)
                        }
                        
                        Button("Done") {
                            addSelectedItems()
                            dismiss()
                        }
                        .bold()
                        .disabled(selectedItems.isEmpty)
                    }
                }
            }
        }
    }
    
    // addCustomItem removed
    
    // ... existing addSelectedItems ...
    
    private func addSelectedItems() {
        let allMasterItems = categories.flatMap { $0.items }
        let itemsToAdd = allMasterItems.filter { selectedItems.contains($0.id) }
        
        var currentOrderIndex = trip.items.count
        
        for masterItem in itemsToAdd {
            if let categoryName = masterItem.category?.name {
                let newItem = PackingItem(name: masterItem.name, category: categoryName)
                newItem.orderIndex = currentOrderIndex
                trip.items.append(newItem)
                currentOrderIndex += 1
            }
        }
    }
}

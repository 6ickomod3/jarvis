import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Bindable var trip: Trip
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PackingCategory.name) private var allCategories: [PackingCategory]
    
    @State private var showingEditTrip = false
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
                TripHeaderView(
                    trip: trip,
                    progress: progress,
                    showingEditTrip: $showingEditTrip,
                    showingItemSelector: $showingItemSelector
                )
                .listRowBackground(Color.cardBackground)
                
                ForEach(allCategories) { category in
                    TripCategorySection(trip: trip, category: category)
                }
                
                TripOtherItemsSection(trip: trip, allCategories: allCategories)
            }
            .scrollContentBackground(.hidden) // Remove default List gray background
        }
        .navigationTitle("Packing List")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingItemSelector) {
            ItemSelectionView(trip: trip)
        }
        .sheet(isPresented: $showingEditTrip) {
            EditTripSheet(trip: trip)
        }
    }
}

// MARK: - Header Section
struct TripHeaderView: View {
    @Bindable var trip: Trip
    var progress: Double
    @Binding var showingEditTrip: Bool
    @Binding var showingItemSelector: Bool
    
    var durationString: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: trip.startDate, to: trip.endDate)
        let days = (components.day ?? 0) + 1
        let nights = max(0, days - 1)
        return "\(days) Days, \(nights) Nights"
    }
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(trip.destination)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primaryText)
                    
                    Spacer()
                    
                    Button(action: { showingEditTrip = true }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.brandPrimary)
                    }
                    .buttonStyle(.plain)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) - \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.body)
                        .foregroundStyle(Color.secondaryText)
                    
                    Text(durationString)
                        .font(.subheadline)
                        .foregroundStyle(Color.brandPrimary)
                }
                
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
    }
}

// MARK: - Category Section
struct TripCategorySection: View {
    @Bindable var trip: Trip
    let category: PackingCategory
    @Environment(\.modelContext) private var modelContext
    
    var items: [PackingItem] {
        trip.items.filter { $0.category == category.name }.sorted(by: { $0.orderIndex < $1.orderIndex })
    }
    
    var body: some View {
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
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
            }
            .listRowBackground(Color.cardBackground)
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                // Find the item in the *trip* list that corresponds to the item at this index in the *filtered* list
                if let itemIndex = trip.items.firstIndex(where: { $0.id == items[index].id }) {
                    let itemToDelete = trip.items[itemIndex]
                    trip.items.remove(at: itemIndex)
                    modelContext.delete(itemToDelete)
                }
            }
        }
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        var movingItems = items
        movingItems.move(fromOffsets: source, toOffset: destination)
        
        for (index, item) in movingItems.enumerated() {
            item.orderIndex = index
        }
    }
}

// MARK: - Other Items Section
struct TripOtherItemsSection: View {
    @Bindable var trip: Trip
    let allCategories: [PackingCategory]
    @Environment(\.modelContext) private var modelContext
    
    var otherItems: [PackingItem] {
        trip.items.filter { item in
            !allCategories.contains { $0.name == item.category }
        }.sorted(by: { $0.orderIndex < $1.orderIndex })
    }
    
    var body: some View {
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
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
            }
            .listRowBackground(Color.cardBackground)
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                if let itemIndex = trip.items.firstIndex(where: { $0.id == otherItems[index].id }) {
                    let itemToDelete = trip.items[itemIndex]
                    trip.items.remove(at: itemIndex)
                    modelContext.delete(itemToDelete)
                }
            }
        }
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        var movingItems = otherItems
        movingItems.move(fromOffsets: source, toOffset: destination)
        
        for (index, item) in movingItems.enumerated() {
            item.orderIndex = index
        }
    }
}

// MARK: - Subviews
struct EditTripSheet: View {
    @Bindable var trip: Trip
    @Environment(\.dismiss) private var dismiss
    
    @State private var destination: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Details") {
                    TextField("Destination", text: $destination)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Trip")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        trip.destination = destination
                        trip.startDate = startDate
                        trip.endDate = endDate
                        dismiss()
                    }
                    .disabled(destination.isEmpty)
                }
            }
            .onAppear {
                destination = trip.destination
                startDate = trip.startDate
                endDate = trip.endDate
            }
        }
    }
}

struct TripItemRow: View {
    @Bindable var item: PackingItem
    @State private var showingEdit = false
    @State private var newQuantity = 1
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation(.spring(duration: 0.2)) {
                    item.isPacked.toggle()
                }
            }) {
                Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(item.isPacked ? Color.accentSuccess : Color.brandSecondary)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                newQuantity = item.quantity
                showingEdit = true
            }) {
                HStack {
                    if item.quantity > 1 {
                        Text("\(item.quantity)x")
                            .fontWeight(.bold)
                            .foregroundStyle(Color.brandPrimary)
                    }
                    
                    Text(item.name)
                        .font(.body)
                        .strikethrough(item.isPacked)
                        .foregroundStyle(item.isPacked ? Color.secondaryText : Color.primaryText)
                    
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .alert("Edit Quantity", isPresented: $showingEdit) {
            TextField("Quantity", value: $newQuantity, format: .number)
                .keyboardType(.numberPad)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                if newQuantity > 0 {
                    item.quantity = newQuantity
                }
            }
        } message: {
            Text("Enter a quantity for \(item.name).")
        }
    }
}

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

import SwiftUI
import SwiftData

struct ManagePoolView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PackingCategory.name) private var categories: [PackingCategory]
    
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var newCategoryIcon = "list.bullet"
    
    var body: some View {
        List {
            ForEach(categories) { category in
                EditableCategoryRow(category: category)
            }
            .onDelete(perform: deleteCategories)
            
            Button(action: { showingAddCategory = true }) {
                Label("Add Category", systemImage: "plus")
                    .foregroundStyle(Color.brandPrimary)
            }
        }
        .navigationTitle("Packing Pool")
        .alert("New Category", isPresented: $showingAddCategory) {
            TextField("Name", text: $newCategoryName)
            Button("Cancel", role: .cancel) { }
            Button("Add") { addCategory() }
        }
    }
    
    private func addCategory() {
        guard !newCategoryName.isEmpty else { return }
        let category = PackingCategory(name: newCategoryName, icon: "cube.box") // Default icon, could be picker
        modelContext.insert(category)
        newCategoryName = ""
    }
    
    private func deleteCategories(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(categories[index])
            }
        }
    }
}

// MARK: - Editable Category Row
struct EditableCategoryRow: View {
    @Bindable var category: PackingCategory
    @State private var showingRename = false
    @State private var newName = ""
    
    var body: some View {
        NavigationLink(destination: ManageItemsView(category: category)) {
            Text(category.name)
        }
        .swipeActions(edge: .leading) {
            Button("Rename") {
                newName = category.name
                showingRename = true
            }
            .tint(.orange)
        }
        .alert("Rename Category", isPresented: $showingRename) {
            TextField("Name", text: $newName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                if !newName.isEmpty {
                    category.name = newName
                }
            }
        }
    }
}

// MARK: - Manage Items View with Editing
struct ManageItemsView: View {
    @Bindable var category: PackingCategory
    @Environment(\.modelContext) private var modelContext
    @State private var newItemName = ""
    
    // For editing items
    @State private var itemToEdit: MasterPackingItem?
    @State private var editName = ""
    
    var body: some View {
        List {
            Section("Items in \(category.name)") {
                ForEach(category.items.sorted(by: { $0.createdAt < $1.createdAt })) { item in
                    Text(item.name)
                        .swipeActions(edge: .leading) {
                            Button("Rename") {
                                itemToEdit = item
                                editName = item.name
                            }
                            .tint(.orange)
                        }
                }
                .onDelete(perform: deleteItems)
                
                HStack {
                    TextField("New Item", text: $newItemName)
                        .onSubmit(addItem)
                        .submitLabel(.done)
                    
                    Button(action: addItem) {
                        Text("Add")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(newItemName.isEmpty ? Color.gray : Color.brandPrimary)
                            .cornerRadius(8)
                    }
                    .disabled(newItemName.isEmpty)
                }
            }
        }
        .navigationTitle(category.name)
        .alert("Rename Item", isPresented: Binding(
            get: { itemToEdit != nil },
            set: { if !$0 { itemToEdit = nil } }
        )) {
            TextField("Name", text: $editName)
            Button("Cancel", role: .cancel) { itemToEdit = nil }
            Button("Save") {
                if let item = itemToEdit, !editName.isEmpty {
                    item.name = editName.capitalized
                }
                itemToEdit = nil
            }
        }
    }
    
    private func addItem() {
        guard !newItemName.isEmpty else { return }
        withAnimation {
            // Capitalize first letter of each word
            let capitalizedName = newItemName.capitalized
            let item = MasterPackingItem(name: capitalizedName, category: category)
            modelContext.insert(item)
            // Relationship is auto-updated by SwiftData usually, but explicit append is safe
            category.items.append(item) 
            newItemName = ""
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            let sortedItems = category.items.sorted(by: { $0.createdAt < $1.createdAt })
            for index in offsets {
                modelContext.delete(sortedItems[index])
            }
        }
    }
}

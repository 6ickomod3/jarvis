import SwiftUI
import SwiftData

// MARK: - Core Trip Models

@Model
final class Trip {
    var id: UUID
    var destination: String
    var startDate: Date
    var endDate: Date
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade) var items: [PackingItem] = []
    
    init(destination: String, startDate: Date, endDate: Date) {
        self.id = UUID()
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = Date()
    }
}

// MARK: - Global Pool Models

@Model
final class PackingCategory {
    var id: UUID
    var name: String
    var icon: String // SF Symbol name
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \MasterPackingItem.category) 
    var items: [MasterPackingItem] = []
    
    init(name: String, icon: String = "list.bullet") {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.createdAt = Date()
    }
}

@Model
final class MasterPackingItem {
    var id: UUID
    var name: String
    var createdAt: Date
    
    var category: PackingCategory?
    
    init(name: String, category: PackingCategory? = nil) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.createdAt = Date()
    }
}

// MARK: - Instance Models (Per Trip)

@Model
final class PackingItem {
    var id: UUID
    var name: String
    var category: String // Reverted from categoryName to match old schema
    var isPacked: Bool
    var quantity: Int = 1 // Default value for migration
    var orderIndex: Int = 0 // Default value for migration
    var createdAt: Date
    
    // Inverse relationship
    var trip: Trip?
    
    init(name: String, category: String = "Other", isPacked: Bool = false, quantity: Int = 1) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.isPacked = isPacked
        self.quantity = quantity
        self.orderIndex = 0 // Default
        self.createdAt = Date()
    }
}

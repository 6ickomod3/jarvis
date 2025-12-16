import SwiftUI
import SwiftData
import Foundation

@Model
class FoodItem {
    var id: UUID
    var name: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    
    // Optional: Reference to a 'parent' meal if strict hierarchy is needed, 
    // but SwiftData handles inverse relationships if defined.
    // For now, we assume FoodItem is unique to a MealEntry (one-to-many from Meal -> Items).
    
    init(name: String, calories: Int, protein: Double = 0, carbs: Double = 0, fat: Double = 0) {
        self.id = UUID()
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }
}

@Model
class MealEntry {
    var id: UUID
    var timestamp: Date
    var mealTypeRaw: String
    
    // When we delete a meal, delete its food items.
    @Relationship(deleteRule: .cascade) var items: [FoodItem] = []
    
    var mealType: MealType {
        get { MealType(rawValue: mealTypeRaw) ?? .snack }
        set { mealTypeRaw = newValue.rawValue }
    }
    
    init(timestamp: Date = Date(), mealType: MealType) {
        self.id = UUID()
        self.timestamp = timestamp
        self.mealTypeRaw = mealType.rawValue
    }
}

enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    
    var icon: String {
        switch self {
        case .breakfast: return "cup.and.saucer.fill"
        case .lunch: return "fork.knife"
        case .dinner: return "wineglass.fill"
        case .snack: return "carrot.fill"
        }
    }
}

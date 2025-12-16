import SwiftUI
import SwiftData

struct AddFoodView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var selectedMealType: MealType = .snack
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                Form {
                    Section {
                        Picker("Meal Type", selection: $selectedMealType) {
                            ForEach(MealType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                    } header: {
                        Text("Meal Details")
                    }
                    .listRowBackground(Color.cardBackground)
                    
                    Section {
                        TextField("Name (e.g., Banana)", text: $name)
                            .foregroundStyle(Color.primaryText)
                        
                        TextField("Calories", text: $calories)
                            .keyboardType(.numberPad)
                            .foregroundStyle(Color.primaryText)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Protein")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryText)
                                TextField("0", text: $protein)
                                    .keyboardType(.decimalPad)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Carbs")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryText)
                                TextField("0", text: $carbs)
                                    .keyboardType(.decimalPad)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Fat")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryText)
                                TextField("0", text: $fat)
                                    .keyboardType(.decimalPad)
                            }
                        }
                    } header: {
                        Text("Food Item")
                    }
                    .listRowBackground(Color.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Log Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.brandPrimary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveFood()
                    }
                    .bold()
                    .foregroundStyle(Color.brandPrimary)
                    .disabled(name.isEmpty || calories.isEmpty)
                }
            }
        }
    }
    
    func saveFood() {
        let calInt = Int(calories) ?? 0
        let pDouble = Double(protein) ?? 0
        let cDouble = Double(carbs) ?? 0
        let fDouble = Double(fat) ?? 0
        
        let foodItem = FoodItem(name: name, calories: calInt, protein: pDouble, carbs: cDouble, fat: fDouble)
        let meal = MealEntry(mealType: selectedMealType)
        meal.items.append(foodItem)
        
        modelContext.insert(meal)
        dismiss()
    }
}

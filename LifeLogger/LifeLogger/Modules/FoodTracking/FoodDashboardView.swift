import SwiftUI
import SwiftData

struct FoodDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealEntry.timestamp, order: .reverse) private var meals: [MealEntry]
    
    @State private var showingAddFood = false
    
    // Temporary Targets (should be settings)
    let targetCalories = 2500
    let targetProtein: Double = 180
    let targetCarbs: Double = 250
    let targetFat: Double = 80
    
    var todayMeals: [MealEntry] {
        meals.filter { Calendar.current.isDateInToday($0.timestamp) }
    }
    
    var dailyTotals: (calories: Int, protein: Double, carbs: Double, fat: Double) {
        todayMeals.reduce((0, 0, 0, 0)) { partialResult, meal in
            meal.items.reduce(partialResult) { totals, item in
                (
                    totals.0 + item.calories,
                    totals.1 + item.protein,
                    totals.2 + item.carbs,
                    totals.3 + item.fat
                )
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    CalorieRingView(
                        calories: dailyTotals.calories,
                        targetCalories: targetCalories,
                        protein: dailyTotals.protein,
                        targetProtein: targetProtein,
                        carbs: dailyTotals.carbs,
                        targetCarbs: targetCarbs,
                        fat: dailyTotals.fat,
                        targetFat: targetFat
                    )
                    .padding(.top)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    // Recent Meals
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Meals")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(Color.primaryText)
                            .padding(.horizontal)
                        
                        if todayMeals.isEmpty {
                            Text("No meals logged yet.")
                                .foregroundStyle(Color.secondaryText)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        } else {
                            ForEach(todayMeals) { meal in
                                MealCard(meal: meal)
                            }
                        }
                    }
                    .padding(.bottom, 80) // Space for FAB
                }
            }
            
            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showingAddFood = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.brandPrimary)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Food Logger") // Usually hidden in custom UI but good for back
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddFood) {
            AddFoodView()
        }
    }
}

struct MealCard: View {
    var meal: MealEntry
    
    var totalCalories: Int {
        meal.items.reduce(0) { $0 + $1.calories }
    }
    
    var body: some View {
        HStack {
            Image(systemName: meal.mealType.icon)
                .font(.title2)
                .foregroundStyle(Color.brandPrimary)
                .frame(width: 50, height: 50)
                .background(Color.appBackground)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(meal.mealTypeRaw)
                    .font(.headline)
                    .foregroundStyle(Color.primaryText)
                Text(meal.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(totalCalories)")
                    .font(.headline)
                    .foregroundStyle(Color.primaryText)
                Text("kcal")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

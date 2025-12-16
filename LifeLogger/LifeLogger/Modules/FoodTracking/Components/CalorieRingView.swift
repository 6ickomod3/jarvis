import SwiftUI

struct CalorieRingView: View {
    var calories: Int
    var targetCalories: Int
    var protein: Double
    var targetProtein: Double
    var carbs: Double
    var targetCarbs: Double
    var fat: Double
    var targetFat: Double
    
    var body: some View {
        HStack(spacing: 20) {
            // Main Calorie Ring
            ZStack {
                Circle()
                    .stroke(Color.cardBackground, lineWidth: 15)
                
                Circle()
                    .trim(from: 0, to: progress(value: Double(calories), target: Double(targetCalories)))
                    .stroke(
                        Color.calorieRing,
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring, value: calories)
                
                VStack {
                    Text("\(targetCalories - calories)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primaryText)
                    Text("Kcal Left")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
            }
            .frame(width: 150, height: 150)
            
            // Macros
            VStack(alignment: .leading, spacing: 12) {
                MacroRow(label: "Protein", value: protein, target: targetProtein, color: .proteinRing)
                MacroRow(label: "Carbs", value: carbs, target: targetCarbs, color: .carbsRing)
                MacroRow(label: "Fat", value: fat, target: targetFat, color: .fatRing)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
    
    func progress(value: Double, target: Double) -> CGFloat {
        guard target > 0 else { return 0 }
        return min(CGFloat(value / target), 1.0)
    }
}

struct MacroRow: View {
    var label: String
    var value: Double
    var target: Double
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
                Spacer()
                Text("\(Int(value))/\(Int(target))g")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(Color.primaryText)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appBackground)
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(color)
                        .frame(width: min(geo.size.width * (value / target), geo.size.width), height: 6)
                }
            }
            .frame(height: 6)
        }
        .frame(width: 120)
    }
}

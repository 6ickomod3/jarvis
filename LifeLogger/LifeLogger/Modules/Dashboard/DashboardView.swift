import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Good Morning,")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                            Text("Jarvis")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primaryText)
                        }
                        Spacer()
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.primaryText)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Simple Module Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        // Food Module
                        NavigationLink(destination: FoodDashboardView()) {
                            ModuleCard(title: "Food", icon: "carrot.fill", color: Color.calorieRing)
                        }
                        
                        // Travel Module
                        NavigationLink(destination: TravelDashboardView()) {
                            ModuleCard(title: "Travel", icon: "airplane.circle.fill", color: Color.brandPrimary)
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        }
    }
}

struct ModuleCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(color)
                .padding(.bottom, 8)
            
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.primaryText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    DashboardView()
}


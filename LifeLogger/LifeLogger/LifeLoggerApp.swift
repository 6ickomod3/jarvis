import SwiftUI
import SwiftData

@main
struct LifeLoggerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Trip.self,
            PackingItem.self,
            PackingCategory.self,
            MasterPackingItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .tint(Color.brandPrimary)
                .onAppear {
                    seedData()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func seedData() {
        let context = sharedModelContainer.mainContext
        
        // Check if categories exist
        let descriptor = FetchDescriptor<PackingCategory>()
        let existingCount = try? context.fetchCount(descriptor)
        
        if existingCount == 0 {
            let nordicCategories = [
                ("Hygiene", "cross.case.fill"),
                ("Camera", "camera.fill"),
                ("Border Control", "passport.fill"),
                ("Medicine", "pills.fill"),
                ("Hiking", "figure.hiking"),
                ("Clothings", "tshirt.fill"),
                ("Electronics", "laptopcomputer")
            ]
            
            for (name, icon) in nordicCategories {
                let category = PackingCategory(name: name, icon: icon)
                context.insert(category)
            }
            
            try? context.save()
            print("Seeded Nordic Categories")
        }
    }
}

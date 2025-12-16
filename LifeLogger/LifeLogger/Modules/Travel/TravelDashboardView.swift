import SwiftUI
import SwiftData

struct TravelDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate, order: .forward) private var trips: [Trip]
    
    @State private var showingAddTrip = false
    
    var upcomingTrips: [Trip] {
        trips.filter { $0.endDate >= Date() }
    }
    
    var pastTrips: [Trip] {
        trips.filter { $0.endDate < Date() }
    }
    
    var body: some View {
        List {
            if !upcomingTrips.isEmpty {
                Section("Upcoming") {
                    ForEach(upcomingTrips) { trip in
                        NavigationLink(destination: TripDetailView(trip: trip)) {
                            TripRow(trip: trip)
                        }
                    }
                    .onDelete(perform: deleteTrips)
                }
            }
            
            if !pastTrips.isEmpty {
                Section("Past") {
                    ForEach(pastTrips) { trip in
                        NavigationLink(destination: TripDetailView(trip: trip)) {
                            TripRow(trip: trip)
                        }
                    }
                    .onDelete(perform: deleteTrips)
                }
            }
            
            if trips.isEmpty {
                ContentUnavailableView("No Trips", systemImage: "airplane", description: Text("Plan your next adventure."))
            }
        }
        .navigationTitle("Travel")
        .toolbar {

            
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddTrip = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddTrip) {
            AddTripView()
        }
    }
    
    private func deleteTrips(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(trips[index])
            }
        }
    }
}

struct TripRow: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(trip.destination)
                .font(.headline)
            Text(trip.startDate.formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        TravelDashboardView()
            .modelContainer(for: Trip.self, inMemory: true)
    }
}

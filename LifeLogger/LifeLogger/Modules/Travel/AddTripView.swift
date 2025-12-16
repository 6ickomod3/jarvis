import SwiftUI
import SwiftData

struct AddTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 3) // Default 3 days
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Where to?") {
                    TextField("Destination", text: $destination)
                }
                
                Section("When?") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                }
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addTrip()
                    }
                    .disabled(destination.isEmpty)
                }
            }
        }
    }
    
    private func addTrip() {
        let newTrip = Trip(destination: destination, startDate: startDate, endDate: endDate)
        modelContext.insert(newTrip)
        dismiss()
    }
}

#Preview {
    AddTripView()
        .modelContainer(for: Trip.self, inMemory: true)
}

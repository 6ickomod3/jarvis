import SwiftUI
import PhotosUI

struct DashboardView: View {
    @State private var profileImage: Image?
    @State private var selectedItem: PhotosPickerItem?
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Good Morning,"
        case 12..<17: return "Good Afternoon,"
        case 17..<22: return "Good Evening,"
        default: return "Good Night,"
        }
    }
    
    var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greeting)
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                            Text("Ji")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primaryText)
                            Text(currentDateString)
                                .font(.caption)
                                .foregroundStyle(Color.brandPrimary)
                                .padding(.top, 2)
                        }
                        
                        Spacer()
                        
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            if let profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.brandPrimary, lineWidth: 2))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(Color.secondaryText)
                            }
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    profileImage = Image(uiImage: uiImage)
                                    saveImageToDocuments(data: data)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Removed Spacer to move grid higher as requested
                    
                    // Simple Module Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        // Travel Module
                        NavigationLink(destination: TravelDashboardView()) {
                            ModuleCard(title: "Travel", icon: "airplane.circle.fill", color: Color.brandPrimary)
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .onAppear(perform: loadProfileImage)
        }
    }
    
    private func saveImageToDocuments(data: Data) {
        let filename = getDocumentsDirectory().appendingPathComponent("profile_photo.jpg")
        try? data.write(to: filename)
    }
    
    private func loadProfileImage() {
        let filename = getDocumentsDirectory().appendingPathComponent("profile_photo.jpg")
        if let data = try? Data(contentsOf: filename), let uiImage = UIImage(data: data) {
            profileImage = Image(uiImage: uiImage)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
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
        .frame(height: 180) // Slightly taller for emphasis
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    DashboardView()
}


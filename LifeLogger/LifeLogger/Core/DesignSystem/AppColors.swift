import SwiftUI
import UIKit

extension Color {
    // MARK: - Brand Colors
    static let brandPrimary = Color(light: "#5D7B93", dark: "#8DA9C4") // Muted Slate Blue
    static let brandSecondary = Color(light: "#E0E0E0", dark: "#3A3A3A") // Soft Grey
    
    // MARK: - Surfaces
    /// Main app background (Off-white / Soft Black)
    static let surfaceBackground = Color(light: "#F5F7FA", dark: "#121212")
    
    /// Cards, lists, floating elements (White / Charcoal)
    static let cardBackground = Color(light: "#FFFFFF", dark: "#2C2C2C")
    
    // MARK: - Text
    static let primaryText = Color(light: "#2C3E50", dark: "#E0E6ED")
    static let secondaryText = Color(light: "#7F8C8D", dark: "#95A5A6")
    
    // MARK: - Accents
    static let accentSuccess = Color(light: "#7BAE7F", dark: "#9BC79F") // Muted Sage
    static let accentWarning = Color(light: "#E1B16F", dark: "#F2CA95") // Muted Orange
    static let accentError = Color(light: "#C0392B", dark: "#E74C3C")   // Soft Red

    
    // MARK: - Legacy / Specific Mappings (Maintaining backward compatibility where needed)
    static let appBackground = surfaceBackground
    
    // Food Specific (Keeping these vivid but slightly adjusted if needed, currently mostly same)
    static let calorieRing = Color(hex: "FF9F0A")
    static let proteinRing = Color(hex: "FF453A")
    static let carbsRing = Color(hex: "32D74B")
    static let fatRing = Color(hex: "FFD60A")
    
    // MARK: - Helper for Dynamic Colors
    init(light: String, dark: String) {
        self.init(uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(hex: dark)
            } else {
                return UIColor(hex: light)
            }
        })
    }
    
    // MARK: - Helper for Hex
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Extension to make UIColor(hex:) available for the dynamic provider
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue:  CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

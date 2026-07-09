import SwiftUI
import UIKit

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 1, 1, 0)
        }
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, alpha: Double(a) / 255)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }

    static let inkNavy = Color(hex: "1B2A4A")
    static let inkGold = Color(hex: "C9A227")
    static let inkParchment = Color(hex: "F5F0E1")
    static let inkSlate = Color(hex: "4A5568")

    static var dynamicBackground: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: "0D1117") : UIColor(hex: "FAF8F2") })
    }
    static var dynamicSurface: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: "1C2333") : UIColor.white })
    }
    static var dynamicText: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: "F0E6D3") : UIColor(hex: "1B2A4A") })
    }
    static var dynamicSecondaryText: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: "8B9CB5") : UIColor(hex: "5C6B8A") })
    }
}

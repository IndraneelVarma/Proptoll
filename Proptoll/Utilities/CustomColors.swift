import SwiftUI

extension Color {
    static let customPrimary = Color("CustomPrimary")
    static let customSecondary = Color("CustomSecondary")
    static let customBackground = Color("CustomBackground")
    static let customAccent = Color("CustomAccent")
    
    // You can also define colors using RGB values
    static let customRed = Color(red: 1.0, green: 0.0, blue: 0.0)
    static let customGreen = Color(red: 0.0, green: 0.8, blue: 0.0)
    static let customBlue = Color(red: 0.0, green: 0.0, blue: 1.0)
    
    // Or using hex values
    static let customPurple = Color(hex: 0x800080)
    static let customOrange = Color(hex: 0xFFA500)
}

// Helper initializer for hex colors
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

import SwiftUI

struct CustomTheme {
    // MARK: - Font
    struct FontTheme {
        static let largeTitle = Font.custom("Avenir-Heavy", size: 34)
        static let title = Font.custom("Avenir-Medium", size: 28)
        static let headline = Font.custom("Avenir-Roman", size: 22)
        static let body = Font.custom("Avenir-Book", size: 17)
        static let caption = Font.custom("Avenir-Light", size: 12)
    }
    
    // MARK: - Colors
    struct ColorTheme {
        static let primary = Color("PrimaryColor")
        static let secondary = Color("SecondaryColor")
        static let accent = Color("AccentColor")
        static let background = Color("BackgroundColor")
        static let text = Color("TextColor")
    }
    
    // MARK: - Spacing
    struct SpacingTheme {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
}

// MARK: - View Extension
extension View {
    func applyCustomTheme() -> some View {
        self
            .accentColor(CustomTheme.ColorTheme.accent)
            .background(CustomTheme.ColorTheme.background)
            .foregroundColor(CustomTheme.ColorTheme.text)
    }
}

// MARK: - Preview Provider
struct CustomTheme_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: CustomTheme.SpacingTheme.medium) {
            Text("Large Title")
                .font(CustomTheme.FontTheme.largeTitle)
            Text("Title")
                .font(CustomTheme.FontTheme.title)
            Text("Headline")
                .font(CustomTheme.FontTheme.headline)
            Text("Body")
                .font(CustomTheme.FontTheme.body)
            Text("Caption")
                .font(CustomTheme.FontTheme.caption)
            Button("Accent Button") {}
                .padding()
                .background(CustomTheme.ColorTheme.accent)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .applyCustomTheme()
    }
}

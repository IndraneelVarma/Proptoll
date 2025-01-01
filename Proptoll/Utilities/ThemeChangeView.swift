import SwiftUI

struct ThemeChangeView: View {
    var scheme: ColorScheme
    @Environment(\.colorScheme) private var systemColorScheme // Add this to detect system theme
    @AppStorage("userTheme") private var userTheme: Theme = .system // Change default to .system
    @Namespace private var animation
    
    var body: some View {
        Toggle(isOn: Binding(
            get: {
                switch userTheme {
                case .system:
                    return systemColorScheme == .dark
                default:
                    return userTheme == .dark
                }
            },
            set: { newValue in
                userTheme = newValue ? .dark : .light
            }
        )) {
            EmptyView()
        }
        .toggleStyle(CustomThemeToggleStyle())
        .environment(\.colorScheme, scheme)
    }
}

// CustomThemeToggleStyle remains the same

enum Theme: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    func color(_ scheme: ColorScheme) -> Color {
        switch self {
        case .system:
            return scheme == .dark ? .blue : .orange
        case .light:
            return .orange
        case .dark:
            return .blue
        }
    }
    
    var colorScheme: ColorScheme {
        switch self {
        case .system:
            @Environment(\.colorScheme) var systemScheme
            return systemScheme
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

struct CustomThemeToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                ZStack {
                    Capsule()
                        .fill(configuration.isOn ? .bluePurple : .gray)
                        .frame(width: 50, height: 30)
                    
                    Circle()
                        .fill(.onMainTheme)
                        .shadow(radius: 1)
                        .frame(width: 22, height: 22)
                        .overlay {
                            Group {
                                if configuration.isOn {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .offset(x: configuration.isOn ? 10 : -10)
                }
            }
        }
        .animation(.spring(duration: 0.2), value: configuration.isOn)
    }
}



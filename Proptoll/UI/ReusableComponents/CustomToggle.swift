import SwiftUI

struct CustomToggle: ToggleStyle {
    let onImage: String
    let offImage: String
    
    init(onImage: String = "bell", offImage: String = "bell.slash") {
        self.onImage = onImage
        self.offImage = offImage
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            ZStack {
                // Standard Toggle appearance
                Rectangle()
                    .foregroundColor(configuration.isOn ? .bluePurple : .gray)
                    .frame(width: 50, height: 30)
                    .cornerRadius(15)
                
                // White circle with icon
                Circle()
                    .fill(.onMainTheme)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Image(systemName: configuration.isOn ? onImage : offImage)
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                    )
                    .offset(x: configuration.isOn ? 10 : -10)
                    .animation(.spring(), value: configuration.isOn)
            }
            .onTapGesture {
                withAnimation {
                    configuration.isOn.toggle()
                }
            }
        }
    }
}

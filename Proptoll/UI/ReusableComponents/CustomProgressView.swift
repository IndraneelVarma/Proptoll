import SwiftUI

struct CustomProgressView: View {
    @State private var isRotating = false
    
    var color: Color
    var lineWidth: CGFloat
    var size: CGFloat
    var duration: Double
    
    var body: some View {
        Circle()
            .trim(from: 0.5, to: 0.9) // Creates a partial circle (line)
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round
                )
            )
            .frame(width: size, height: size)
            .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
            .onAppear {
                withAnimation(
                    .linear(duration: duration)
                    .repeatForever(autoreverses: false)
                ) {
                    isRotating = true
                }
            }
    }
}

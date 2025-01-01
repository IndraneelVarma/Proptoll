import SwiftUI

struct InitialProfileImage: View {
    let username: String
    let size: CGFloat
    let backgroundColor: Color
    let textColor: Color
    
    var initials: String {
        username
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .map { $0.prefix(1).uppercased() }
            .prefix(2)
            .joined()
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
            
            Text(initials)
                .font(.custom("Montserrat-Medium", size: size * 0.4))
                .foregroundColor(textColor)
        }
        .frame(width: size, height: size)
    }
}





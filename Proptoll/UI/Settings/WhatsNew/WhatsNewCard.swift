import SwiftUI

struct WhatsNewCard: View {
    var image: String
    var mainText: String
    var subText: String
    var body: some View {
        VStack{
            HStack{
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 22.5)
                    .padding()
                    .foregroundStyle(.primary)
                
                
                Text(mainText)
                    .font(.custom("Montserrat-Regular", size: 16))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if !whatsNewShown{
                    Circle()
                        .frame(width: 7.5, height: 7.5)
                        .foregroundStyle(.green)
                }
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 22.5)
                    .padding()
                    .foregroundStyle(.primary)
            }
            
            Divider()
                .padding(.horizontal, 20)
        }
    }
}

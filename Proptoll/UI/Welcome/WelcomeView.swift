import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack{
            VStack{
                Text("Welcome")
                    .padding()
                Text(mainName)
                    .font(.title)
                    .bold()
                    .padding()
                
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.green)
                    .frame(height: 60)
                
                Text("You're all set")
                    .fontWeight(.medium)
                    .padding()
                
                // NavigationLink should act as the button
                NavigationLink(destination: HomePageView()) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30))
                        .background(Color.purple)
                        .cornerRadius(20)
                        .padding()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    WelcomeView()
}

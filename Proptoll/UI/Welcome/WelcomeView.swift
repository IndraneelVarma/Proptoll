import SwiftUI

struct WelcomeView: View {
    @StateObject private var viewModel = OwnerViewModel()
    @State private var fetching = true
    @State private var showHome = false
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
                
                Text(fetching ? "getting things ready.." : "You're all set")
                    .fontWeight(.medium)
                    .padding()
                
                // NavigationLink should act as the button
                Button{
                    matomoTracker.track(eventWithCategory: "Continue Button", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                    Task{
                        await viewModel.fetchOwner(jsonQuery:[
                            "filter[where][name]":mainName,
                            "filter[include][0][relation]": "plots"
                        ])
                    }
                    showHome = true
                } label: {
                    HStack{
                        Text(fetching ? "Optimizing..." : "Continue")
                        if fetching {
                            ProgressView()
                        }
                    }
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30))
                    .background(fetching ? .gray : .purple)
                    .cornerRadius(20)
                    .padding()
                }
                .disabled(fetching)
                            }
            .navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $showHome, destination: {
            HomePageView()
        })
        .onAppear(){
            matomoTracker.track(view: ["Welcome Page"])
            UserDefaults.standard.set(true, forKey: "notis")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5){
                fetching = false
            }
        }
        
    }
}

#Preview {
    WelcomeView()
}

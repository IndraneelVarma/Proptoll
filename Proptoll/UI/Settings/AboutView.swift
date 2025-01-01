import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack{
            Color(.mainTheme)
                .ignoresSafeArea(.all)
            ScrollView {
                VStack(spacing: 30) {
                    // App Logo and Name Section
                    VStack(spacing: 15) {
                        Image(.proptollIconNoname)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.orange)
                            .frame(height: 60)
                        
                        Text("PropToll")
                            .font(.custom("Montserrat-Bold", size: 28))
                            .foregroundStyle(.bluePurple)
                        
                        Text("Version \(Bundle.main.releaseVersionNumber)")
                            .font(.custom("Montserrat-Regular", size: 15))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Mission Statement
                    Text("Transforming spaces for a better world")
                        .font(.custom("Montserrat-Medium", size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                        .padding(.horizontal)
                    
                    // Links Section
                    VStack(spacing: 20) {
                        linkButton(
                            title: "Privacy Policy",
                            url: "https://proptoll.com/propTollPrivacyPolicy.html"
                        )
                        linkButton(
                            title: "Refund & Cancellation",
                            url: "https://proptoll.com/RefundAndCancellation.html"
                        )
                    }
                    .padding(.vertical)
                    
                    Spacer()
                    
                    // Footer Section
                    VStack(spacing: 4) {
                        Text("© 2024 PropToll")
                            .font(.custom("Montserrat-Regular", size: 14))
                            .foregroundStyle(.secondary)
                        
                        
                        Button {
                            UIApplication.shared.open(URL(string: "https://metapointer.com/#/home")!)
                        } label: {
                            Text("Metapointer Labs Private Limited")
                                .font(.custom("Montserrat-Regular", size: 14))
                                .tint(.specialText)
                        }
                        
                        
                        
                        Text("All rights reserved")
                            .font(.custom("Montserrat-Regular", size: 14))
                            .foregroundStyle(.secondary)
                        
                        
                    }
                    .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
        }
    }
    
    private func linkButton(title: String, url: String) -> some View {
        Button {
            UIApplication.shared.open(URL(string: url)!)
        } label: {
            HStack {
                Text(title)
                    .font(.custom("Montserrat-Medium", size: 16))
                    .foregroundStyle(.primary)
                
                
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(LinearGradient(
                            colors: [Color("lavender500"), Color("BluePurple")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .tint(.primary)
    }
}

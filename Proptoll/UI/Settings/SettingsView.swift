//
//  ProfileView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 09/08/24.
//

import SwiftUI


struct SettingsView: View {
    @State private var changeTheme = false
    @State private var isNotificationOn = false
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject var router: Router
    @State private var showCookie = false
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    var body: some View {
        NavigationStack{
            ZStack{
                ScrollView{
                    HStack{
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding()
                            .foregroundStyle(.primary)
                        Text(mainName)
                            .font(.title)
                            .bold()
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .background(Color(UIColor.systemGray4) )
                    .offset(y:1)
                    
                    VStack{
                        HStack{
                            Text("General")
                                .font(.title)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))
                        HStack{
                            RoundedRectangle(cornerRadius: 10)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 2)
                        
                        NavigationLink(destination: ProfileView()){
                            ProfileCardView(image: "person.fill", mainText: "Profile", subText: "Account details")
                        }
                        .foregroundStyle(.primary)
                        
                        NavigationLink(destination: UserGuideView()){
                            ProfileCardView(image: "person.2.circle.fill", mainText: "User Guide", subText: "View app features")
                        }
                        .foregroundStyle(.primary)
                        
                        ProfileCardView(image: "person.2.circle.fill", mainText: "What's New", subText: "View the changes added in the current verison")
                        
                        
                    }
                    .background(Color(UIColor.systemGray4) )
                    
                    VStack{
                        HStack{
                            Text("Settings")
                                .font(.title)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))
                        HStack{
                            RoundedRectangle(cornerRadius: 10)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 2)
                        HStack{
                            Button("Change Theme", action: {
                                changeTheme.toggle()
                            })
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
                            .tint(.primary)
                            Spacer()
                        }
                        Toggle("Notifications",systemImage: "bell.badge.fill" ,isOn: $isNotificationOn)
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            .tint(.orange)
                            .foregroundStyle(.primary)
                        
                    }
                    .background(Color(UIColor.systemGray4) )
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    
                    VStack(alignment: .leading){
                        HStack{
                            Text("Community Contact")
                                .font(.title)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))
                        HStack{
                            RoundedRectangle(cornerRadius: 10)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 2)
                        HStack{
                            Text("Krishna Mohan Choudary")
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 10))
                        
                        HStack{
                            Text("9346833440")
                                .foregroundStyle(.primary)
                            Button{
                                UIPasteboard.general.string = "9346833440"
                                showCookie = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showCookie = false
                                    }
                                }
                            }
                        label:{
                            Image(systemName: "paperclip")
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                                .foregroundStyle(.primary)
                        }
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
                        Button{
                            
                        }
                    label:
                        {
                            HStack{
                                Image(systemName: "phone.fill")
                                    .foregroundStyle(.orange)
                                Text("Call")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 25)
                                .fill(.primary))
                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 21))
                        
                        Text("Available on all working days")
                            .foregroundStyle(.primary)
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 0))
                        
                    }
                    .background(Color(UIColor.systemGray4) )
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    
                    HStack(){
                        
                        Spacer()
                        
                        NavigationLink(destination: LoginView())
                        {
                            HStack{
                                Image(systemName: "arrow.backward.square")
                                    .foregroundStyle(.orange)
                                Text("Logout")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 25)
                                .fill(.primary))
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            router.reset()
                            UserDefaults.standard.dictionaryRepresentation().keys.forEach { key in
                                UserDefaults.standard.removeObject(forKey: key)
                            }
                        })
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                        
                        
                        
                        Spacer()
                        
                    }
                    .background(Color(UIColor.systemGray4) )
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    
                    HStack(){
                        
                        Spacer()
                        
                        VStack{
                            HStack{
                                Image(systemName: "house")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.orange)
                                    .frame(height: 35)
                                Text("PropToll")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(.primary)
                            }
                            Text("Version X.X.X")
                                .foregroundStyle(.primary)
                        }
                        .padding()
                        
                        Spacer()
                        
                    }
                    .background(Color(UIColor.systemGray4) )
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    
                    Spacer()
                }
                if showCookie {
                    VStack {
                        Spacer()
                        Text("Copied to clipboard!")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .transition(.move(edge: .bottom))
                    }
                    .zIndex(1) // Ensure the cookie appears above other content
                    .animation(.easeInOut, value: showCookie)
                    .opacity(0.85)
                }
            }
            .onAppear(){
                matomoTracker.track(view: ["Settings Page"])
            }
            .preferredColorScheme(userTheme.colorScheme)
            .sheet(isPresented: $changeTheme, content: {
                ThemeChangeView(scheme: scheme)
                //sinc max height of themeChangeView is 410
                    .presentationDetents([.height(410)])
                    .presentationBackground(.clear)
            })
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(Router())
}


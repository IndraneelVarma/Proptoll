//
//  ProfileView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 09/08/24.
//

import SwiftUI

struct ProfileView: View {
    @State private var changeTheme = false
    @State private var isNotificationOn = false
    @Environment(\.colorScheme) private var scheme
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    var body: some View {
        NavigationStack{
            ScrollView{
                HStack{
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                        .padding()
                        .foregroundStyle(.white)
                    Text("Dummy Name")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.white)
                    Spacer()
                }
                .background(.gray)
                .offset(y:1)
                
                VStack{
                    HStack{
                        Text("General")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))
                    HStack{
                        RoundedRectangle(cornerRadius: 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 2)
                    HStack{
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding()
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading){
                            Text("Profile")
                                .font(.title)
                                .bold()
                                .foregroundStyle(.white)
                            Text("Account details")
                                .font(.system(size: 13))
                                .foregroundStyle(.white)
                            HStack{
                                RoundedRectangle(cornerRadius: 10)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 2)
                        }
                        Spacer()
                    }
                    .background(.gray)
                    
                    
                    HStack{
                        Image(systemName: "person.2.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding()
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading){
                            Text("User Guide")
                                .font(.title)
                                .bold()
                                .foregroundStyle(.white)
                            Text("View app features")
                                .font(.system(size: 13))
                                .foregroundStyle(.white)
                            HStack{
                                RoundedRectangle(cornerRadius: 10)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 2)
                        }
                        Spacer()
                    }
                    .background(.gray)
                    
                    
                    HStack{
                        Image(systemName: "person.2.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding()
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading){
                            Text("What's new")
                                .font(.title)
                                .bold()
                                .foregroundStyle(.white)
                            Text("View the changes added in current version")
                                .font(.system(size: 13))
                                .foregroundStyle(.white)
                            HStack{
                                RoundedRectangle(cornerRadius: 10)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 2)
                        }
                        Spacer()
                    }
                    .background(.gray)
                    
                    
                }
                .background(.gray)
                
                VStack{
                    HStack{
                        Text("Settings")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
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
                        .tint(.white)
                        Spacer()
                    }
                    Toggle("Notifications",systemImage: "bell.badge.fill" ,isOn: $isNotificationOn)
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                        .tint(.orange)
                        .foregroundStyle(.white)
                    
                }
                .background(.gray)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                
                VStack(alignment: .leading){
                    HStack{
                        Text("Community Contact")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))
                    HStack{
                        RoundedRectangle(cornerRadius: 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 2)
                    HStack{
                        Text("Krishna Mohan Choudary")
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 10))
                    
                    HStack{
                        Text("9346833440")
                            .foregroundStyle(.white)
                        Image(systemName: "paperclip")
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                            .foregroundStyle(.white)
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
                                .foregroundStyle(.orange)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25)
                            .fill(Color.primary))
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 21))
                    
                    Text("Available on all working days")
                        .foregroundStyle(.white)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 0))
                    
                }
                .background(.gray)
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
                                .foregroundStyle(.orange)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25)
                            .fill(Color.primary))
                    }
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    
                   Spacer()
                    
                }
                .background(.gray)
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
                                .foregroundStyle(.white)
                        }
                        Text("Version X.X.X")
                            .foregroundStyle(.white)
                    }
                    .padding()
                    
                   Spacer()
                    
                }
                .background(.gray)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                
                Spacer()
            }
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

#Preview {
    ProfileView()
}

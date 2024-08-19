//
//  ProfileView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 16/08/24.
//

import SwiftUI

struct ProfileView: View {
    @State private var showSheet = false
    @StateObject var viewModel = ProfileViewModel()
    var body: some View {
        VStack{
            TopBarView(showSheet: $showSheet)
            
            HStack{
                Text(mainName)
                    .font(.title)
                    .bold()
                Spacer()
            }
            .padding()
            
            HStack{
                Text(mainPhoneNumber)
                    .font(.title)
                    .bold()
                Spacer()
            }
            .padding()
            
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray)
                .shadow(radius: 5)
                .frame(width: 350, height: 300)
                .overlay(
                    GeometryReader { geometry in
                        VStack(spacing: 0) {
                            HStack{
                                Image(systemName: "link")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                    .foregroundStyle(.orange)
                                    .padding(.trailing)
                                VStack(alignment: .leading){
                                    Text("Aadhar Linked")
                                    Text(((viewModel.profile.first?.isAadharLinked) == true) ? "Yes" : "No")
                                }
                                Spacer()
                            }
                                .frame(height: geometry.size.height / 4)
                            Divider()
                            HStack{
                                Image(systemName: "staroflife")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                    .foregroundStyle(.orange)
                                    .padding(.trailing)
                                VStack(alignment: .leading){
                                    Text("Tarriff Category")
                                    Text(viewModel.profile.first?.tarrifCategory ?? "No data")
                                }
                                Spacer()
                            }
                                .frame(height: geometry.size.height / 4)
                            Divider()
                            HStack{
                                Image(systemName: "folder")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                    .foregroundStyle(.orange)
                                    .padding(.trailing)
                                VStack(alignment: .leading){
                                    Text("ADF Status")
                                    Text((viewModel.profile.first?.adfStatus == true) ? "Applicable" : "Not Applicable")
                                }
                                Spacer()
                            }
                                .frame(height: geometry.size.height / 4)
                            Divider()
                            HStack{
                                Image(systemName: "house")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                    .foregroundStyle(.orange)
                                    .padding(.trailing)
                                VStack(alignment: .leading){
                                    Text("No. of Floors")
                                    Text("\(viewModel.profile.first?.noOfFloors ?? -5)")
                                }
                                Spacer()
                            }
                                .frame(height: geometry.size.height / 4)
                        }
                    }
                        .padding()
                )
            
            Spacer()
        }
        .navigationTitle("Profile")
        .sheet(isPresented: $showSheet, content: {
            SheetView().presentationDetents([.fraction(0.4)])
        })
        .onAppear(){
                viewModel.fetchProfile(authToken: jwtToken)
        }
        
    }
}

#Preview {
    ProfileView()
}

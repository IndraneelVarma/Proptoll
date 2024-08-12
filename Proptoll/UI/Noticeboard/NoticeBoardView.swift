//
//  HomePage.swift
//  Proptoll
//
//  Created by Indraneel Varma on 07/08/24.
//

import SwiftUI

struct NoticeBoardView: View {
    var body: some View {
        NavigationStack{
            GeometryReader{ geometry in
                VStack(spacing:0){
                    ZStack{
                        Color.gray
                            .frame(height: geometry.safeAreaInsets.top)
                            .ignoresSafeArea(.all)
                        
                        HStack{
                            
                            Image(systemName: "house")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding()
                            
                            Text("Noticeboard")
                            
                            Spacer()
                            
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding()
                            NavigationLink(destination: ProfileView()) {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.white)
                            }
                            
                            
                        }.frame(width: 375, alignment: .leading)
                        
                    }.background(Color.gray)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.purple)
                                .frame(width: 50, height: 30)
                                .overlay(
                                    Text("All")
                                )
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.purple)
                                .frame(width: 75, height: 30)
                                .overlay(
                                    Text("General")
                                )
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.purple)
                                .frame(width: 100, height: 30)
                                .overlay(
                                    Text("Information")
                                )
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.purple)
                                .frame(width: 55, height: 30)
                                .overlay(
                                    Text("Alert")
                                )
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.purple)
                                .frame(width: 100, height: 30)
                                .overlay(
                                    Text("Emergency")
                                )
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.purple)
                                .frame(width: 65, height: 30)
                                .overlay(
                                    Text("Event")
                                )
                        }
                        .padding()
                    }
                    ScrollView(showsIndicators: false){
                        VStack(spacing: 16)
                        {
                            NoticeBoardcardView()
                            NoticeBoardcardView()
                            NoticeBoardcardView()
                            NoticeBoardcardView()
                            NoticeBoardcardView()
                        }
                        .padding()
                    }
                    Spacer()
                    
                    
                }
                
            }
            
        }
    }
}


#Preview {
    NoticeBoardView()
}

//
//  BillView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 07/08/24.
//

import SwiftUI

struct ReceiptsView: View {
    @State private var showSheet = false
    @State var x = 1
    @State var y = 10
    var body: some View {
        NavigationStack{
            GeometryReader{ geometry in
                VStack(alignment: .center, spacing:0){
                    ZStack{
                        Color.gray
                            .frame(height: geometry.safeAreaInsets.top)
                            .ignoresSafeArea(.all)
                        
                        HStack{
                            
                            Image(systemName: "house")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding()
                            
                            Text("Receipts")
                            
                            Spacer()
                            
                            
                            NavigationLink(destination: ProfileView()) {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.white)
                            }
                            
                            
                        }.frame(width: 375, alignment: .leading)
                        
                    }.background(Color.gray)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.purple)
                        .frame(width: 370, height: 30)
                        .overlay(
                            HStack{
                                Image(systemName: "chevron.down")
                                Text("Dummy Plot Dummy Data")
                            }
                                .frame(width:330, alignment: .leading)
                        )
                        .padding(EdgeInsets(top: 15, leading: 10, bottom: 10, trailing: 10))
                        .onTapGesture {
                            showSheet.toggle()
                        }
                    
                    HStack{
                        Text("Total Paid")
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        Spacer()
                    }
                    HStack{
                        Text("$ \(100)")
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                    
                    HStack{
                        RoundedRectangle(cornerRadius: 10)
                        
                    }
                    .frame(width: .infinity, height: 2)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    
                    HStack{
                        Text("Receipts")
                        Spacer()
                        Menu {
                            Button(action: {
                                // Action for the first option
                                x = 1
                                y = 10
                            }) {
                                Text("1-10")
                            }
                            
                            Button(action: {
                                // Action for the second option
                                x = 11
                                y = 20
                            }) {
                                Text("11-20")
                            }
                            
                            Button(action: {
                                // Action for the third option
                                x = 21
                                y = 30
                            }) {
                                Text("21-30")
                            }
                            Button(action: {
                                // Action for the third option
                                x = 31
                                y = 40
                            }) {
                                Text("31-40")
                            }
                            Button(action: {
                                // Action for the third option
                                x = 41
                                y = 50
                            }) {
                                Text("41-50")
                            }
                            Button(action: {
                                // Action for the third option
                                x = 51
                                y = 60
                            }) {
                                Text("51-60")
                            }
                            Button(action: {
                                // Action for the third option
                                x = 61
                                y = 70
                            }) {
                                Text("61-70")
                            }
                            Button(action: {
                                // Action for the third option
                                x = 71
                                y = 80
                            }) {
                                Text("71-80")
                            }
                            Button(action: {
                                // Action for the third option
                                x = 81
                                y = 90
                            }) {
                                Text("81-90")
                            }
                            Button(action: {
                                // Action for the third option
                                x = 91
                                y = 100
                            }) {
                                Text("90-100")
                            }
                        } label: {
                            Text("\(x)-\(y)")
                                .foregroundColor(.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                )
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                    ScrollView(showsIndicators: false){
                            ForEach(x...y, id: \.self){ index in
                                ReceiptsCardView(x: index)
                        }
                    }
                    
                }
            }
        }.sheet(isPresented: $showSheet, content: {
            SheetView().presentationDetents([.fraction(0.4)])
        })
    }
}

#Preview {
    ReceiptsView()
}

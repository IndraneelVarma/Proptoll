//
//  BillView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 07/08/24.
//

import SwiftUI

struct ReceiptsView: View {
    @StateObject var viewModel = BillsViewModel()
    @State private var showSheet = false
    @State private var year: Int = 2024
    @State private var showingSettings = false
    @State var totalPaid = 0
    @State private var showProgress = true
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
                                .foregroundColor(.white)
                            
                            Text("Receipts")
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.white)
                            }
                            
                            
                        }.frame(width: 375, alignment: .leading)
                        
                    }.background(Color.gray)
                    
                    TopBarView(showSheet: $showSheet)
                    
                    HStack{
                        Text("Total Paid")
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        Spacer()
                    }
                    HStack{
                        Text("₹ \(totalPaid)")
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                    
                    HStack{
                        RoundedRectangle(cornerRadius: 10)
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: 2)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    
                    HStack{
                        Text("Receipts")
                        Spacer()
                        Menu {
                            Button(action: {
                                // Action for the first option
                                year = 2024
                            }) {
                                Text("2024")
                            }
                            
                            Button(action: {
                                // Action for the second option
                                year = 2023
                            }) {
                                Text("2023")
                            }
                        } label: {
                            Text("Year \(year)")
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
                        if(viewModel.bills.isEmpty)
                        {
                            VStack {
                                if showProgress {
                                    ProgressView()
                                } else {
                                    Text("No results found")
                                }
                            }
                            .onAppear {
                                showProgress = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                    showProgress = false
                                }
                            }
                        }
                        else
                        {
                            ForEach(viewModel.bills, id: \.self){ bill in
                                if(bill.dueAmount != 0){
                                    ReceiptsCardViewMain(bill: bill)
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        .onChange(of: year, { oldValue, newValue in
            Task{
                await viewModel.fetchBills(jsonQuery:["filter[limit]": 12,
                                                      "filter[where][bill_year]": year,
                                                      "filter[where][plot_id]": plotId,])
            }
        })
        .fullScreenCover(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
                    .navigationBarItems(leading: Button("Back") {
                        showingSettings = false
                    })
                    .navigationBarTitle("Settings", displayMode: .inline)
            }
        }
        .onAppear()
        {
            Task{
                await viewModel.fetchBills(jsonQuery:["filter[limit]": 12,
                                                      "filter[where][bill_year]": 2024,
                                                      "filter[where][plot_id]": plotId,])
            }
        }
        .sheet(isPresented: $showSheet, content: {
            SheetView().presentationDetents([.fraction(0.4)])
        })
    }
}

#Preview {
    ReceiptsView()
}

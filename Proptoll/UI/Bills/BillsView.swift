//
//  BillView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 07/08/24.
//

import SwiftUI
import Sentry

struct BillsView: View {
    @StateObject var viewModel = BillsViewModel()
    @StateObject var viewModel2 = BillsViewModel()
    @StateObject var viewModel3 = OwnerViewModel()
    @State private var showSheet = false
    @State private var year: String = "2024"
    @State private var showingSettings = false
    @State private var showingPayScreen = false
    @State private var showProgress = true
    
    var body: some View {
        NavigationStack{
            GeometryReader{ geometry in
                VStack(alignment: .center, spacing:0){
                    ZStack{
                        Color(UIColor.systemGray4) 
                            .frame(height: geometry.safeAreaInsets.top)
                            .ignoresSafeArea(.all)
                        
                        HStack{
                            
                            Image(systemName: "house")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding()
                                .foregroundColor(.primary)
                            
                            Text("Bills")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            
                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.primary)
                            }
                            .padding(.horizontal)
                            
                            
                        }.frame(width: 375, alignment: .leading)
                        
                    }.background(Color(UIColor.systemGray4) )
                    
                    TopBarView(showSheet: $showSheet)
                    
                    HStack{
                        Text("Total Due")
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        Spacer()
                    }
                    HStack{
                        Text("₹\(viewModel2.bills.first?.dueAmount ?? 404)")
                        Spacer()
                        Button(action: {
                            matomoTracker.track(eventWithCategory: "pay now", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                            showingPayScreen = true
                        }, label: {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.purple)
                                .frame(width: 90,height: 40)
                                .overlay{
                                    Text("Pay Now")
                                        .foregroundStyle(.white)
                                }
                        })
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                    
                    HStack{
                        RoundedRectangle(cornerRadius: 10)
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: 2)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    
                    HStack{
                        Text("Bills")
                        Spacer()
                        Menu {
                            Button(action: {
                                // Action for the first option
                                year = "2024"
                            }) {
                                Text("2024")
                            }
                            
                            Button(action: {
                                // Action for the second option
                                year = "2023"
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
                                        .fill(Color(UIColor.systemGray) .opacity(0.2))
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
                                BillsCardView(bill: bill)
                                    .padding(.horizontal)
                                
                            }
                        }
                    }
                    
                }
            }
        }
        .fullScreenCover(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
                    .navigationBarItems(leading: Button("Back") {
                        showingSettings = false
                    })
                    .navigationBarTitle("Settings", displayMode: .inline)
            }
        }
        .fullScreenCover(isPresented: $showingPayScreen) {
            NavigationStack {
                PaymentsView(amount: viewModel2.bills.first?.dueAmount ?? 0, year: Int(year) ?? 0)
                    .navigationBarItems(leading: Button("Back") {
                        showingPayScreen = false
                    })
                    .navigationBarTitle("Payment", displayMode: .inline)
            }
        }
        .onChange(of: year, { oldValue, newValue in
            Task{
                await viewModel.fetchBills(jsonQuery:[
                    
                    "filter[order]": "bill_month DESC",
                    "filter[limit]": 20,
                    "filter[where][bill_year]": year,
                    "filter[where][plot_id]": plotId,
                    
                ])
                await viewModel2.fetchBills(jsonQuery:[
                    "filter[order]": "bill_month DESC",
                    "filter[limit]": 1,
                    "filter[where][bill_year]": year,
                    "filter[where][plot_id]": plotId,
                    
                ])
            }
        })
        .onAppear()
        {
            matomoTracker.track(view: ["Bills Page"])
            year = "2024"
            Task{
                await viewModel.fetchBills(jsonQuery:[
                    "filter[order]": "id DESC",
                    "filter[limit]": 20,
                    "filter[where][bill_year]": 2024,
                    "filter[where][plot_id]": plotId,
                    
                ])
                await viewModel2.fetchBills(jsonQuery:[
                    "filter[order]": "id DESC",
                    "filter[limit]": 1,
                    "filter[where][bill_year]": 2024,
                    "filter[where][plot_id]": plotId,
                ])

            }
        }
        .sheet(isPresented: $showSheet, content: {
            SheetView().presentationDetents([.fraction(0.4)])
        })
    }
}
func convertToURLEncodedString(from dictionary: [String: Any]) -> String? {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
    } catch {
        print("Error converting dictionary to JSON: \(error)")
    }
    return nil
}

#Preview {
    BillsView()
}

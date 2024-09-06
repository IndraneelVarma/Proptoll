//
//  PaymentsView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 29/08/24.
//
import MatomoTracker
import SwiftUI

struct PaymentsView: View {
    @StateObject private var viewModel = BillsViewModel()
    @StateObject private var viewModel2 = PaymentsViewModel()
    @State private var selectedOption = 0
    @State private var text: String = ""
    @State var amount: Int
    @State private var webViewOpen = false
    var year: Int
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                
                Text("Total Due")
                    .font(.title)
                    .padding()
                
                
                
                Text("₹\(viewModel.bills.first?.dueAmount ?? 404)")
                    .padding(.horizontal)
                
                HStack{
                    RoundedRectangle(cornerRadius: 10)
                }
                .frame(maxWidth: .infinity, maxHeight: 2)
                .padding()
                
                SelectableOption(
                    title: "Pay total due: ₹\(viewModel.bills.first?.dueAmount ?? 404)",
                    subTitle: "Clear your current dues in one go",
                    isSelected: selectedOption == 0,
                    action: {amount = viewModel.bills.first?.dueAmount ?? 0; selectedOption = 0}
                )
                .padding()
                SelectableOption2(
                    title: "Pay custom amount",
                    subTitle: "Customize your Payment Amount",
                    isSelected: selectedOption == 1,
                    action: { selectedOption = 1 }, textInput: $text
                )
                .onTapGesture {
                    print(amount)
                }
                .padding(.horizontal)
                
                Text("Payment Details")
                    .font(.title2)
                    .padding()
                Text("Plot Number: 2001")
                    .padding(.horizontal)
                Text("Name: \(mainName)")
                    .padding(.horizontal)
                Text("Phone Number: \(mainPhoneNumber)")
                    .padding(.horizontal)
                
                Spacer()
                
                HStack{
                    Spacer()
                    
                    Button(action: {
                        if selectedOption == 1{
                            amount = Int(text) ?? 0
                        }
                        if(amount > 0){
                            Task{
                                await viewModel2.postPayRequest(jsonQuery:[:], amount: amount)
                            }
                            webViewOpen = true
                        }
                    }, label: {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.purple)
                            .frame(maxWidth: 400,maxHeight: 40)
                            .overlay{
                                Text("Proceed to payment")
                                    .font(.system(size: 17.5))
                                    .foregroundStyle(.white)
                            }
                    })
                    
                    Spacer()
                }
                .padding()
                
            }
        }
        .fullScreenCover(isPresented: $webViewOpen) {
            NavigationStack {
                PaymentWebView(html: viewModel2.paymentHtml)
                    .navigationBarItems(leading: Button("Back") {
                        webViewOpen = false
                    })
                    .navigationBarTitle("Payment", displayMode: .inline)
            }
        }
        .onAppear(){
            matomoTracker.track(view: ["Payment Initial Page"])
            Task{
                await viewModel.fetchBills(jsonQuery:[
                    "filter[order]": "bill_month DESC",
                    "filter[limit]": 1,
                    "filter[where][bill_year]": year,
                    "filter[where][plot_id]": plotId,
                    
                ])
            }
        }
    }
    struct SelectableOption: View {
        let title: String
        let subTitle: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .fill(isSelected ? Color.blue : Color.clear)
                                .frame(width: 16, height: 16)
                        )
                    
                    VStack(alignment: .leading){
                        Text(title)
                            .font(.system(size: 17.5))
                            .bold()
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        Text(subTitle)
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                    }
                    Spacer()
                    
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
            }
        }
    }
    struct SelectableOption2: View {
        let title: String
        let subTitle: String
        let isSelected: Bool
        let action: () -> Void
        @Binding var textInput: String
        
        var body: some View {
            VStack(spacing: 0) {
                Button(action: action) {
                    HStack {
                        Circle()
                            .stroke(Color.blue, lineWidth: 2)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .fill(isSelected ? Color.blue : Color.clear)
                                    .frame(width: 16, height: 16)
                            )
                        
                        VStack(alignment: .leading) {
                            Text(title)
                                .font(.system(size: 17.5))
                                .bold()
                                .foregroundColor(.primary)
                            Text(subTitle)
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(isSelected ? 10 : 10)
                }
                
                if isSelected {
                    VStack {
                        HStack {
                            Text("₹")
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                            TextField("Enter amount", text: $textInput)
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(10)
                        .padding(.top, 1) // Small gap to separate from the button
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                }
            }
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .animation(.easeInOut, value: isSelected)
        }
    }
}

#Preview {
    PaymentsView(amount: 0, year: 2024)
}

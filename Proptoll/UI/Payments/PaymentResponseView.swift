//
//  PaymentResponseView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 20/09/24.
//

import SwiftUI

struct PaymentResultView: View {
    let status: PaymentStatus
    @Binding var webViewOpen: Bool
    
    var body: some View {
        VStack {
            Image(systemName: status == .success ? "checkmark.circle" : "xmark.circle")
                .font(.system(size: 60))
                .foregroundColor(status == .success ? .green : .red)
            
            Text(status == .success ? "Payment Successful" : "Payment Failed")
                .font(.title)
                .padding()
            
            Text(status == .success ? "Your payment was processed successfully." : "There was an issue processing your payment. Please try again.")
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                webViewOpen = false
            }) {
                Text("Close")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}




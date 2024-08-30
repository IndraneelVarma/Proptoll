//
//  PaymentSuccessOrFailView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 30/08/24.
//

import SwiftUI



struct PaymentSuccessOrFailView: View {
    var result: String
    var body: some View {
       if result == "success" || result == "Success"
        {
           PaymentSuccessView()
       }
        else
        {
            PaymentFailView()
        }
    }
}




struct PaymentSuccessView: View {
    var body: some View {
        Text("Success")
    }
}

struct PaymentFailView: View {
    var body: some View {
        Text("Failure")
    }
}

#Preview {
    PaymentSuccessOrFailView(result: "")
}

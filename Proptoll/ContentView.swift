//
//  ContentView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 07/08/24.
//

import SwiftUI

struct ContentView: View {
    @State var phoneNumber: String
    var body: some View {
        Text("Welcome to PropToll")
            .font(.system(size: 32, weight: .medium, design: .default))
            .foregroundStyle(.primary)
            .padding(EdgeInsets(top: 50, leading: 0, bottom: 0, trailing: 0))
        
        TextField("Enter phone number", text: $phoneNumber)
            .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.primary, lineWidth: 2)
                )
            .padding()
        Button{
            
        }label: {
            Text("Login")
                .foregroundColor(.primary)
                        .padding(EdgeInsets(top: 10, leading: 120, bottom: 10, trailing: 120))
                        .background(Color.purple)
                        .cornerRadius(20)
        }
        
        Spacer()
        
    }
}

#Preview {
    ContentView(phoneNumber: "")
}

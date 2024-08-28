//
//  OtpTextField.swift
//  Proptoll
//
//  Created by Indraneel Varma on 13/08/24.
//

import SwiftUI

struct OtpTextField: View {
    @Binding var otp: String
    
    var body: some View {
        VStack {
            ZStack {
                // Centered placeholder text
                if otp.isEmpty {
                    Text("Enter OTP here")
                        .foregroundColor(Color(UIColor.systemGray4) )
                        .font(.system(size: 18))
                }

                // TextField for user input
                TextField("", text: $otp)
                    .keyboardType(.numberPad) // Set keyboard type to number pad
                    .multilineTextAlignment(.center) // Center the text as it's entered
                    .padding()
                    .background(Color(UIColor.systemGray4) .opacity(0.2)) // Light gray background
                    .cornerRadius(10) // Rounded corners
                    .onChange(of: otp) {
                        formatEnteredText()
                    }
            }
            .padding()
        }
        .frame(width: 250)
    }
    
    private func formatEnteredText() {
        // Remove any existing spaces
        var digitsOnly = otp.replacingOccurrences(of: " ", with: "")
        
        // Ensure only digits are present
        digitsOnly = digitsOnly.filter { $0.isNumber }
        
        // Limit to 6 digits
        if digitsOnly.count > 6 {
            digitsOnly = String(digitsOnly.prefix(6))
        }
        
        // Insert a space after every character
        otp = digitsOnly.enumerated().map { index, character in
            return index > 0 ? "    \(character)" : "\(character)"
        }.joined()
    }
}

#Preview {
    LoginView()
}

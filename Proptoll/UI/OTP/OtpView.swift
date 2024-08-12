//
//  OTPView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 12/08/24.
//

import SwiftUI

struct OTPView: View {
    @State var phoneNumber: String
    @State var message: String
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    @State private var token: String = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showHomePage = false
    private let viewModel = OtpViewModel()
    @State private var otp: String = ""
    var body: some View {
        NavigationStack{
            VStack{
                Text("Phone Verification")
                    .font(.title)
                    .italic()
                    .padding()
                Image(systemName: "ellipsis.message")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding()
                Text("Verification code has been sent to your \nregistered mobile number")
                    .multilineTextAlignment(.center)
                    .padding()
                
                OtpFieldView(otp: $otp, numberOfFields: 6)
                    .padding()
                
                Button {
                    Task {
                        do {
                            isLoading = true
                            let response = try await viewModel.login(otp: otp, phoneNumber: phoneNumber, verificationKey: message)
                            token = response.message
                            showHomePage = true
                            errorMessage = nil
                        } catch {
                            errorMessage = error.localizedDescription
                            token = ""
                        }
                        isLoading = false
                        print(token)
                    }
                } label: {
                    Text("Verify OTP")
                        .foregroundColor(.primary)
                        .padding(EdgeInsets(top: 10, leading: 50, bottom: 10, trailing: 50))
                        .background(Color.purple)
                        .cornerRadius(20)
                        .padding()
                }
                .navigationDestination(isPresented: $showHomePage, destination: {
                    HomePageView()
                })
                .disabled(isLoading)
                .padding()
                
                if isLoading {
                    ProgressView()
                }
                
                if errorMessage != nil {
                    Text("Invalid OTP")
                        .foregroundColor(.red)
                        .padding()
                }
                
                if token == "OTP Matched" {
                    Text("success")
                        .foregroundColor(.green)
                        .padding()
                }
            }
        }
        .preferredColorScheme(userTheme.colorScheme)
    }
}

#Preview {
    OTPView(phoneNumber: "", message: "")
}

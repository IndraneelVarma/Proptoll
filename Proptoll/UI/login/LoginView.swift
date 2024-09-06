import SwiftUI
import Foundation
import MatomoTracker

struct LoginView: View {
    @State private var phoneNumber: String = ""
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    @State private var key: String = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showOtpScreen = false
    private let viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Text("Welcome to PropToll")
                        .font(.system(size: 32, weight: .medium, design: .default))
                        .foregroundStyle(.primary)
                        .padding(EdgeInsets(top: 50, leading: 0, bottom: 125, trailing: 0))
                    
                    VStack {
                        Image(systemName: "house")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 65, height: 65)
                            .padding()
                            .foregroundStyle(.orange)
                        
                        Text("Please enter your mobile \n number.")
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        HStack {
                            Text("+91")
                                .foregroundColor(Color(UIColor.systemGray4) )
                                .padding(.leading, 10)
                            TextField("Enter phone number", text: $phoneNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.primary, lineWidth: 2)
                        )
                        .padding(EdgeInsets(top: 10, leading: 45, bottom: 0, trailing: 45))
                        
                        Button {
                            if(phoneNumber.count != 10)
                            {
                                errorMessage = "Please Enter 10 digits"
                            }
                            else{
                                Task {
                                    do {
                                        isLoading = true
                                        let response = try await viewModel.login(phoneNumber: phoneNumber)
                                        key = response.message
                                        UserDefaults.standard.setValue(phoneNumber, forKey: "mainPhoneNumber")
                                        showOtpScreen = true
                                        errorMessage = nil
                                    } catch {
                                        errorMessage = error.localizedDescription
                                        key = ""
                                    }
                                    isLoading = false
                                }
                            }
                        } label: {
                            Text("Login")
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 10, leading: 120, bottom: 10, trailing: 120))
                                .background(Color.purple)
                                .cornerRadius(20)
                                .padding()
                        }
                        .navigationDestination(isPresented: $showOtpScreen, destination: {
                            OTPView(phoneNumber: phoneNumber, message: key)
                        })
                        .disabled(isLoading)
                        
                        if isLoading {
                            ProgressView()
                        }
                        
                        if errorMessage != nil {
                            if(errorMessage != "Please Enter 10 digits"){
                                Text("Invalid Phone Number")
                                    .foregroundColor(.red)
                                    .padding()
                            }
                            else
                            {
                                Text("Please Enter 10 digits")
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                        
                        if !key.isEmpty {
                            Text("success")
                                .foregroundColor(.green)
                                .padding()
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .onAppear(){
                matomoTracker.track(view: ["Login Page"])
            }
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(userTheme.colorScheme)
    }
}

#Preview {
    LoginView()
}

import SwiftUI
import Foundation
import RealmSwift

struct LoginView: View {
    @State private var phoneNumber: String = ""
    @State private var key: String = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showOtpScreen = false
    @State private var keyboardHeight: CGFloat = 0
    private let viewModel = LoginViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer(minLength: 0)
                        
                        Text("Welcome to PropToll")
                            .font(.custom("Montserrat-Medium", size: 27))
                            .foregroundStyle(.primary)
                        
                        Image(.proptollIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 85)
                            .foregroundStyle(.orange)
                        
                        Text("Please enter your mobile number.")
                            .font(.custom("Montserrat-Regular", size: 15))
                            .multilineTextAlignment(.center)
                        
                        HStack {
                            Text("+91")
                                .foregroundColor(Color(UIColor.systemGray4))
                                .padding(.leading, 10)
                            TextField("Enter phone number", text: $phoneNumber)
                                .keyboardType(.numberPad)
                                .frame(height: 50)
                            // Increased height
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.primary, lineWidth: 2)
                        )
                        .padding(.horizontal, 45)
                        
                        Button(action: handleLogin) {
                            Text("Login")
                                .font(.custom("Montserrat-Medium", size: 15))
                                .foregroundColor(.white)
                                .padding(.horizontal, 105)
                                .padding(.vertical, 10)
                                .background(LinearGradient(
                                    colors: [Color("lavender500"), Color("BluePurple")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .cornerRadius(10)
                        }
                        .disabled(isLoading)
                        
                        if isLoading {
                            ProgressView()
                        }
                        
                        if let errorMessage = errorMessage {
                            if networkMonitor.isConnected {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                            }
                            else {
                                Text("No internet connection, try again")
                                    .font(.custom("Montserrat-Regular", size: 15))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        if !key.isEmpty {
                            Text("success")
                                .foregroundColor(.green)
                        }
                        
                        Spacer(minLength: 0)
                        
                        HStack {
                            Spacer()
                            Text("By proceeding, you agree to our")
                                .font(.custom("Montserrat-Regular", size: 13))
                            Button {
                                UIApplication.shared.open(URL(string: "https://proptoll.com/propTollPrivacyPolicy.html")!)
                            } label: {
                                Text("Privacy Policy")
                                    .font(.custom("Montserrat-Regular", size: 13))
                                    .tint(.specialText)
                                    .underline()
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .frame(minHeight: geometry.size.height)
                    .offset(y: -max(keyboardHeight - geometry.safeAreaInsets.bottom, 0) / 2)
                }
                .animation(.easeOut(duration: 0.16), value: keyboardHeight)
            }
        }
        .background(.mainTheme)
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: onAppear)
        .onChange(of: phoneNumber) { newValue in
            if newValue.count > 10 {
                phoneNumber = String(newValue.prefix(10))
            }
        }
        .navigationDestination(isPresented: $showOtpScreen) {
            OTPView(phoneNumber: phoneNumber, message: key)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                keyboardHeight = keyboardRectangle.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
    }
    
    private func handleLogin() {
        matomoTracker.track(eventWithCategory: "login button", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
        if phoneNumber.count != 10 {
            errorMessage = "Please Enter 10 digits"
            matomoTracker.track(eventWithCategory: "short phone number", action: "displayed error \(errorMessage ?? "")", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
        } else {
            Task {
                do {
                    isLoading = true
                    let response = try await viewModel.login(phoneNumber: phoneNumber)
                    key = response.message
                    UserDefaults.standard.setValue(phoneNumber, forKey: "mainPhoneNumber")
                    showOtpScreen = true
                    if showOtpScreen {
                        matomoTracker.track(eventWithCategory: "logged in", action: "success", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                    }
                    errorMessage = nil
                } catch {
                    errorMessage = "Invalid mobile number"
                    matomoTracker.track(eventWithCategory: "login error", action: "failed to login", name: "Error: \(errorMessage ?? "")", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                    key = ""
                }
                isLoading = false
            }
        }
    }
    
    private func onAppear() {
        matomoTracker.track(view: ["Login Page"])
        UIApplication.shared.unregisterForRemoteNotifications()
    }
}


#Preview {
    LoginView()
}

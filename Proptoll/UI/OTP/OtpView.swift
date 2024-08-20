//line 1

import SwiftUI

struct OTPView: View {
    @State var phoneNumber: String
    @State var message: String
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showHomePage = false
    private let viewModel = OtpViewModel()
    @State private var otp: String = ""
    @State private var resendButtonDisabled = true
    @State private var timeRemaining = 90
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
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
                
                OtpTextField(otp: $otp)
                    .padding()
                
                Button {
                    if(otp.count == 26)
                    {
                        Task {
                            do {
                                isLoading = true
                                let response = try await viewModel.verify(otp: otp, phoneNumber: phoneNumber, verificationKey: message)
                                jwtToken = response.token
                                UserDefaults.standard.set(jwtToken, forKey: "jwtToken")
                                mainName = response.name
                                errorMessage = nil
                                showHomePage = true
                            } catch {
                                errorMessage = error.localizedDescription
                                jwtToken = ""
                            }
                            isLoading = false
                        }
                    }
                    else
                    {
                        errorMessage = "Please enter 6 digits"
                    }
                } label: {
                    Text("Verify OTP")
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 10, leading: 50, bottom: 10, trailing: 50))
                        .background(Color.purple)
                        .cornerRadius(20)
                        .padding()
                }
                .navigationDestination(isPresented: $showHomePage, destination: {
                    WelcomeView()
                })
                .disabled(isLoading)
                
                Button {
                    Task {
                        do {
                            isLoading = true
                            let response = try await viewModel.resend(phoneNumber: phoneNumber, message: message)
                            print(response.message)
                            jwtToken = response.message
                            errorMessage = nil
                            resendButtonDisabled = true
                            timeRemaining = 90
                        } catch {
                            errorMessage = error.localizedDescription
                            jwtToken = ""
                        }
                        isLoading = false
                    }
                } label: {
                    Text(resendButtonDisabled ? "Resend (\(timeRemaining)s)" : "Resend OTP")
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 10, leading: 40, bottom: 10, trailing: 40))
                        .background(resendButtonDisabled ? .gray : .purple)
                        .cornerRadius(20)
                        
                }
                .disabled(isLoading || resendButtonDisabled)
                .padding()
                
                if isLoading {
                    ProgressView()
                }
                
                
                if showHomePage {
                    Text("success")
                        .foregroundColor(.green)
                        .padding()
                }
                
                if errorMessage != nil {
                    Text(errorMessage!)
                        .foregroundColor(.red)
                        .padding()
                }
                
            }
        }
        .preferredColorScheme(userTheme.colorScheme)
        .onReceive(timer) { _ in
                    if resendButtonDisabled {
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        } else {
                            resendButtonDisabled = false
                        }
                    }
                }
    }
}

#Preview {
    LoginView()
}

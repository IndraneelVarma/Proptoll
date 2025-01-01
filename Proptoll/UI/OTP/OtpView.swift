import SwiftUI
import SimpleKeychain

struct OTPView: View {
    @State var phoneNumber: String
    @State var message: String
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showHomePage = false
    private let viewModel = OtpViewModel()
    @State private var showLogin = false
    @State private var otp: String = ""
    @State private var resendButtonDisabled = true
    @State private var timeRemaining = 90
    @State private var keyboardHeight: CGFloat = 0
    @State private var message2 = ""
    @State private var timer: Timer?
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var userDefaultsMonitor = UserDefaultsMonitor()
    
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        Spacer(minLength: 0)
                        
                        VStack(spacing: 20) {
                            Text("Phone Verification")
                                .font(.custom("Montserrat-Medium", size: 30))
                                .italic()
                            
                            Image(systemName: "ellipsis.message")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                            
                            Text("Verification code has been sent to your \nregistered mobile number")
                                .font(.custom("Montserrat-Medium", size: 15))
                                .multilineTextAlignment(.center)
                            
                            OtpTextField(otp: $otp)
                                .padding()
                            
                            Button(action: verifyOTP) {
                                Text("Verify OTP")
                                    .foregroundColor(.white)
                                    .padding(EdgeInsets(top: 10, leading: 50, bottom: 10, trailing: 50))
                                    .background(LinearGradient(
                                        colors: [Color("lavender500"), Color("BluePurple")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                      ))
                                    .cornerRadius(10)
                            }
                            .disabled(isLoading)
                            
                            Button(action: resendOTP) {
                                Text(resendButtonDisabled ? "Resend (\(timeRemaining)s)" : "Resend OTP")
                                    .foregroundColor(.primary)
                                    .padding(EdgeInsets(top: 10, leading: 40, bottom: 10, trailing: 40))
                                    .background(.clear)
                            }
                            .disabled(isLoading || resendButtonDisabled)
                            
                            if isLoading {
                                ProgressView()
                            }
                            
                            if showHomePage {
                                Text("success")
                                    .foregroundColor(.green)
                            }
                            
                            if let errorMessage = errorMessage {
                                if networkMonitor.isConnected {
                                    Text(errorMessage)
                                        .foregroundColor(.red)
                                }
                                else {
                                    Text("No internet connection, try again")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        Spacer(minLength: 0)
                    }
                    .padding()
                    .frame(minHeight: geometry.size.height)
                    .offset(y: -max(keyboardHeight - geometry.safeAreaInsets.bottom, 0) / 3)
                }
                .frame(width: geometry.size.width)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: { showLogin = true }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.blue)
            })
        }
        .background(.mainTheme)
        .navigationDestination(isPresented: $showHomePage) {
            WelcomeView()
        }
        .navigationDestination(isPresented: $showLogin) {
            LoginView()
        }
        .onAppear {
            matomoTracker.track(view: ["OTP Page"])
            UserDefaults.standard.set(false, forKey: "fromContentView")
            
            func generateEncryptionKey() -> Data {
                var key = Data(count: 64)
                key.withUnsafeMutableBytes { bufferPointer in
                    guard let baseAddress = bufferPointer.baseAddress else { return }
                    let result = SecRandomCopyBytes(kSecRandomDefault, 64, baseAddress)
                    assert(result == errSecSuccess, "Failed to generate random bytes for encryption key")
                }
                return key
            }

            let key = generateEncryptionKey()
            let key2 = try? keychain.data(forKey: "privateKey")
            if key2 == nil {
                try? keychain.set(key, forKey: "privateKey")
            }
            startTimer()
        }
        .onDisappear {
            stopTimer()
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
        .animation(.easeOut(duration: 0.16), value: keyboardHeight)
    }
    
    private func startTimer() {
        stopTimer() // Ensure any existing timer is invalidated
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if resendButtonDisabled {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    resendButtonDisabled = false
                    stopTimer()
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func verifyOTP() {
        matomoTracker.track(eventWithCategory: "Verify Otp", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
        if otp.count == 26 { //6 digit otp with spaces in textfield auto added
            Task {
                do {
                    isLoading = true
                    
                    if message.count > 5 {
                        message2 = message
                    }
                    else {
                        message2 = UserDefaults.standard.string(forKey: "key") ?? ""
                    }
                    let response = try await viewModel.verify(otp: otp.replacingOccurrences(of: " ", with: ""), phoneNumber: phoneNumber, verificationKey: message2)
                    //UserDefaults.standard.set(response.token, forKey: "jwtToken")
                    try? keychain.set(response.token, forKey: "jwtToken")
                    userDefaultsMonitor.updateMainName(response.name)
                    UserDefaults.standard.set(response.id, forKey: "userId")
                    errorMessage = nil
                    showHomePage = true
                    if showHomePage {
                        matomoTracker.track(eventWithCategory: "Verify Otp", action: "Success", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                    }
                } catch {
                    errorMessage = "Invalid OTP"
                    matomoTracker.track(eventWithCategory: "Verify Otp", action: "error", name: "Error Message: \(errorMessage ?? "")", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                    //UserDefaults.standard.set("", forKey: "jwtToken")
                    try? keychain.set("", forKey: "jwtToken")
                }
                isLoading = false
            }
        } else {
            errorMessage = "Please enter 6 digits"
            matomoTracker.track(eventWithCategory: "Verify Otp", action: "error", name: "Error Message: \(errorMessage ?? "")", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
        }
    }
    
    private func resendOTP() {
        matomoTracker.track(eventWithCategory: "Resend Otp", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
        Task {
            do {
                isLoading = true
                let response = try await viewModel.resend(phoneNumber: phoneNumber, message: message)
                //UserDefaults.standard.set(response.message, forKey: "jwtToken")
                try? keychain.set(response.message, forKey: "jwtToken")
                errorMessage = nil
                resendButtonDisabled = true
                timeRemaining = 90
                startTimer() // Restart the timer when OTP is resent
            } catch {
                errorMessage = "please try again"
                //UserDefaults.standard.set("", forKey: "jwtToken")
                try? keychain.set("", forKey: "jwtToken")
            }
            isLoading = false
        }
    }
}

#Preview {
    OTPView(phoneNumber: "", message: "")
}

import SwiftUI

struct PaymentResultView: View {
    let status: PaymentStatus
    @Binding var webViewOpen: Bool
    @Binding var showPayScreen: Bool
    @Environment(\.dismiss) private var dismiss
    
    private let successColor = Color.green
    private let failureColor = Color.red
    private let buttonColor = Color.blue
    
    private var statusImage: String {
        status == .success ? "checkmark.circle.fill" : "xmark.circle.fill"
    }
    
    private var title: String {
        status == .success ? "Payment Successful" : "Payment Failed"
    }
    
    private var message: String {
        status == .success
            ? "Your payment was processed successfully."
            : "There was an issue processing your payment. Please try again."
    }
    
    // State variable to control the display of the rating alert
    @State private var showRatingAlert = false
    
    // UserDefaults key
    private let hasRatedAppKey = "hasRatedApp"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Status Icon
                Image(systemName: statusImage)
                    .font(.system(size: 80))
                    .foregroundColor(status == .success ? successColor : failureColor)
                    .animation(.easeInOut, value: status)
                
                VStack(spacing: 16) {
                    // Title
                    Text(title)
                        .font(.title.bold())
                    
                    // Message
                    Text(message)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    if status == .failure {
                        Button(action: {
                            webViewOpen = false
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Retry Payment")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(buttonColor)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                    Button(action: { showPayScreen = false }) {
                        Text("Close")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(status == .success ? buttonColor : .secondary)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            matomoTracker.track(view: ["Payment Result Page \(status == .success ? "Success" : "Failure")"])
            if status == .success {
                UserDefaults.standard.set(true, forKey: "paymentStatus")
                UserDefaults.standard.set(true, forKey: "paymentStatus2")
                
                // Check if the user has already rated the app
                let hasRatedApp = UserDefaults.standard.bool(forKey: hasRatedAppKey)
                if !hasRatedApp {
                    // Trigger the rating alert when payment is successful and user hasn't rated yet
                    showRatingAlert = true
                }
            }
        }
        .alert("Enjoying the app?", isPresented: $showRatingAlert) {
            Button("Rate Now") {
                // Replace the URL below with your app's App Store URL
                if let url = URL(string: "https://apps.apple.com/app/id6480278605") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
                // Set the flag to true to prevent future prompts
                UserDefaults.standard.set(true, forKey: hasRatedAppKey)
            }
            Button("Later", role: .cancel) {
                // Do nothing, just dismiss the alert
            }
            Button("Don't Show Again") {
                // Set the flag to true to prevent future prompts
                UserDefaults.standard.set(true, forKey: hasRatedAppKey)
            }
        } message: {
            Text("If you like using the app, please take a moment to rate it. Your feedback helps us improve!")
        }
        .navigationBarBackButtonHidden(true)
    }
}

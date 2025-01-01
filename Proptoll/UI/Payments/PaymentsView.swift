import SwiftUI
import Sentry

class PaymentStateModel: ObservableObject {
    @Published var showingPayScreen = false
}

struct PaymentsView: View {
    @StateObject private var viewModel = InvoiceViewModel()
    @StateObject private var viewModel2 = PaymentsViewModel()
    @State var paymentCheck = 0
    @State private var text: String = ""
    @State var amount: Int
    @State var from: String
    let fixedAmount: Int
    @Binding var showPayScreen: Bool
    @State private var webViewOpen = false
    @State private var isLoading = true
    @State var year: Int
    @State var accountId: String
    @State private var keyboardHeight: CGFloat = 0
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var userDefaultsMonitor = UserDefaultsMonitor()
    let htmlString = """
    <form id="nonseamless" method="post" name="redirect" action="www.google.com">
    <p class="message">Please update your application to the latest version</p>
    <button (click)="updateApp()">Update Now</button>
    <a href="https://proptoll.com/download">Update</a>
    <script language="javascript">
            updateApp() {
                document.redirect.submit();
            }
    </script>
    </form>
    """
    
    init(amount: Int, showPayScreen: Binding<Bool>, year: Int, accountId: String, from: String) {
        self.amount = amount
        self.fixedAmount = amount
        self._showPayScreen = showPayScreen
        self.year = year
        self.accountId = accountId
        self.from = from
    }
    
    var dueAmount: Int {
        viewModel.invoices.reduce(0) { total, invoice in
            if let payment = invoice.payments {
                return total + (Int(payment.amountPaid) ?? 0)
            }
            return total
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 10) {
                    
                        
                        Text(UserDefaults.standard.string(forKey: "organization") ?? "")
                            .font(.custom("Montserrat-Medium", size: 15))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                        Text("Plot: \(UserDefaults.standard.string(forKey: "selectedUnitNumber") ?? "")")
                            .font(.custom("Montserrat-Medium", size: 15))
                            
                        
                   
                }
                .frame(maxWidth: .infinity)
                .padding()
                .padding(.horizontal)
                
                VStack {
                    LargeAmountInput(amount: $text)
                        .padding()
                        .onAppear {
                            text = String(amount)
                        }
                    
                    if let currentAmount = Int(text),from != "account" {
                        if currentAmount > fixedAmount {
                            Text("Excess amount of ₹\(currentAmount - fixedAmount) will get added to account!")
                                .font(.custom("Montserrat-Regular", size: 14))
                                .foregroundColor(.bluePurple)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }
                        else {
                            Text("₹\(currentAmount) will be used to clear existing dues.")
                                .font(.custom("Montserrat-Regular", size: 14))
                                .foregroundColor(.bluePurple)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }
                    }
                    if let currentAmount = Int(text), from == "account" {
                        if fixedAmount > 0 {
                            Text("Account balance of ₹\(currentAmount >= fixedAmount ? fixedAmount : currentAmount) will get deducted towards existing dues!")
                                .font(.custom("Montserrat-Regular", size: 14))
                                .foregroundColor(.bluePurple)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }
                        else {
                            Text("₹\(currentAmount) will be added to your account for future payments.")
                                .font(.custom("Montserrat-Regular", size: 14))
                                .foregroundColor(.bluePurple)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                
                
                    VStack(alignment: .center, spacing: 20) {
                        
                        VStack {
                            //payment rules
                            VStack(alignment: .leading, spacing: 12) {
                                PaymentRulesView(text: "Learn how we handle Payments!", color: .gray)
                            }
                            .padding()
                            
                        }
                        
                        
                    }
                    .ignoresSafeArea(.keyboard)
                
                
                Spacer()
                
                // Payment Button Section
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            amount = Int(Double(text) ?? 0)
                            if amount > 0 {
                                matomoTracker.track(eventWithCategory: "Proceed to Payment (amount \(amount))", action: "tapped", name: "", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                                userDefaultsMonitor.updatePaymentRefreshStatus(true)
                                Task {
                                    await viewModel2.postPayRequest(jsonQuery: [:], amount: amount, accountId: accountId)
                                }
                                dismissKeyboard()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    webViewOpen = true
                                }
                            }
                        }, label: {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(!networkMonitor.isConnected ? LinearGradient(
                                    colors: [.gray, .gray],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) : LinearGradient(
                                    colors: [Color("lavender500"), Color("BluePurple")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(maxWidth: 400)
                                .frame(height: 40)
                                .overlay {
                                    Text("Proceed to payment")
                                        .font(.custom("Montserrat-Regular", size: 16))
                                        .foregroundStyle(.white)
                                }
                        })
                        .disabled(!networkMonitor.isConnected)
                        
                        if !networkMonitor.isConnected {
                            Text("No internet connection, please try again!")
                                .font(.custom("Montserrat-Regular", size: 14))
                                .foregroundStyle(.red)
                        }
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .onChange(of: text) { _ in
            if text.count > 6 {
                text = String(text.prefix(6))
            }
            if text.containsNonNumeric {
                text = String(text.prefix(text.count - 1))
            }
            if Int(text) ?? 0 == 0 {
                text = ""
            }
        }
        .navigationDestination(isPresented: $webViewOpen) {
            NavigationStack {
                PaymentWebView(html: viewModel2.paymentHtml, webViewOpen: $webViewOpen, isLoading: $isLoading, showPayScreen: $showPayScreen)
                    .navigationBarItems(leading: Button {
                        webViewOpen = false
                    }label: {
                        Text("Back")
                            
                    }
                        .tint(.primary))
                    .navigationBarTitle("Payment", displayMode: .inline)
            }
        }
        .onAppear {
            if from == "account" {
                amount = 0
            }
            text = String(amount)
            setupKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        return dateString
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                keyboardHeight = keyboardRectangle.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}


struct LargeAmountInput: View {
    @Binding var amount: String
    @State private var displayAmount: String = ""
    
    private func formatNumber(_ string: String) -> String {
        // Remove any existing commas and non-numeric characters
        let cleanNumber = string.replacingOccurrences(of: ",", with: "")
        
        // Apply validation rules
        var validatedNumber = cleanNumber
        
        // Limit to 6 digits
        if validatedNumber.count > 6 {
            validatedNumber = String(validatedNumber.prefix(6))
        }
        
        // Handle zero case
        if let number = Int(validatedNumber), number == 0 {
            return ""
        }
        
        guard let number = Int(validatedNumber) else { return "" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Enter Amount below (INR)")
                .font(.custom("Montserrat-Medium", size: 16))
                .foregroundColor(.gray)
            
            HStack(alignment: .center) {
                Spacer()
                TextField("", text: $displayAmount)
                    .font(.custom("Montserrat-Bold", size: 32))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    .onChange(of: displayAmount) { newValue in
                        let filtered = newValue.replacingOccurrences(of: ",", with: "")
                            .filter { $0.isNumber }
                        
                        // Apply formatting and validation
                        displayAmount = formatNumber(filtered)
                        
                        // Update the binding with clean number
                        amount = displayAmount.replacingOccurrences(of: ",", with: "")
                    }
                    .overlay(
                        Rectangle()
                            .frame(height: 0.5)
                            .padding(.horizontal, 24)
                            .foregroundColor(.primary)
                            .offset(y: 8),
                        alignment: .bottom
                    )
                Spacer()
            }
        }
        .onAppear {
            // Initialize display amount with formatted value from the amount binding
            displayAmount = formatNumber(amount)
        }
        // Add this to handle external changes to the amount
        .onChange(of: amount) { newAmount in
            if displayAmount.replacingOccurrences(of: ",", with: "") != newAmount {
                displayAmount = formatNumber(newAmount)
            }
        }
    }
}

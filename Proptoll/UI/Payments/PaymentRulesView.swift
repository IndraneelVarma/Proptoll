import SwiftUI

struct PaymentRulesView: View {
    @State private var showPaymentRules = false
    let text: String
    let color: Color
    
    var body: some View {
        NavigationStack {
            Button(action: {
                showPaymentRules = true
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(color)
                        .frame(height: 16)
                    Text(text)
                        .font(.custom("Montserrat-Medium", size: 16))
                        .underline()
                        .foregroundColor(color)
                        .padding(.vertical, 8)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .sheet(isPresented: $showPaymentRules) {
            FullRulesView()
                .presentationDetents([.large])
        }
    }
}

struct ExpandableCard: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(question)
                        .font(.custom("Montserrat-Medium", size: 16))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .animation(.spring(), value: isExpanded)
                }
            }
            .padding()
            
            if isExpanded {
                Text(answer)
                    .font(.custom("Montserrat-Regular", size: 15))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.mainTheme))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ContactCard: View {
    let phoneNumber: String
    let email: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Us")
                .font(.custom("Montserrat-Medium", size: 18))
                .foregroundColor(.primary)
                .padding(.bottom, 4)
            
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(.blue)
                Text(phoneNumber)
                    .font(.custom("Montserrat-Regular", size: 15))
                    .foregroundStyle(.primary)
                    .underline()
                    .onTapGesture {
                        let smsUrl = URL(string: "sms:\(phoneNumber)")!
                        if UIApplication.shared.canOpenURL(smsUrl) {
                            UIApplication.shared.open(smsUrl)
                        }
                    }
            }
            
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.blue)
                Text(email)
                    .font(.custom("Montserrat-Regular", size: 15))
                    .foregroundStyle(.primary)
                    .underline()
                    .onTapGesture {
                        if let mailUrl = URL(string: "mailto:\(email)") {
                            if UIApplication.shared.canOpenURL(mailUrl) {
                                UIApplication.shared.open(mailUrl)
                            }
                        }
                    }
            }
        }
        .padding()
        .background(Color(.cards))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct FullRulesView: View {
    @Environment(\.dismiss) var dismiss
    
    // NEW CONTENT REPLACING OLD PAYMENT RULES
    private let paymentRules = [
        // 1 - 4: Payments & Methods
        (
            question: "What payment methods are available?",
            answer: """
                    You can pay your dues through:
                    • Online (UPI payments through the app)
                    • Cash (directly to the society administration)
                    • Cheque (directly to the society administration)
                    """
        ),
        (
            question: "Can I make advance payments?",
            answer: """
                    Yes! You can make advance payments of any amount. This amount will be stored in your account balance and automatically adjusted and accounted against future invoices.
                    """
        ),
        (
            question: "How does the account balance system work?",
            answer: """
                    Your account balance works like a prepaid wallet:
                    • Any advance payments are added to your balance
                    • When new invoices are generated, the system automatically uses your available balance
                    • If your balance covers only part of an invoice, it will be partially deducted and you'll need to pay the remaining amount
                    """
        ),
        (
            question: "What happens if my account balance is less than the invoice amount?",
            answer: """
                    If your account balance is lower than the total bill amount, our system will automatically use your entire available balance toward the payment and generate an invoice for only the remaining balance. For instance, if your total bill is Rs.1000 and you have Rs.200 in your account, the system will apply your Rs.200 balance automatically and generate an invoice for Rs.800 (the remaining amount)
                    """
        ),
        
        // 5 - 8: Tracking & History
        (
            question: "Where can I view my payment history?",
            answer: """
                    You can access your complete transaction history in the Dashboard's Account Activity section, which shows:
                    • Invoice generations
                    • Payments made
                    • Account balance deductions
                    """
        ),
        (
            question: "How do I get payment receipts?",
            answer: """
                    Receipts are automatically generated for every payment you make. You can view and download all your receipts from the dedicated Receipts screen in the app.
                    """
        ),
        (
            question: "Can I make partial payments?",
            answer: """
                    Yes, you can pay any amount towards an invoice. The remaining balance will stay as due until fully paid.
                    """
        ),
        (
            question: "What happens if I pay more than the invoice amount?",
            answer: """
                    Any excess amount paid will automatically be stored in your account balance and will be used for future invoices.
                    """
        ),
        
        // 9 - 11: Account Management
        (
            question: "How do I check my current account balance?",
            answer: """
                    Your current account balance is always visible in the Dashboard section of the app.
                    """
        ),
        (
            question: "Is there a limit to how much advance payment I can make?",
            answer: """
                    No, there's no upper limit on advance payments. You can add as much amount as you'd like to your account balance.
                    """
        ),
        (
            question: "Are my payment transactions secure?",
            answer: """
                    Yes, all online transactions are processed through secure UPI gateways. The app only facilitates the transaction and doesn't store any sensitive payment information.
                    """
        ),
        
        // 12 - 13: Invoices & Notifications
        (
            question: "How will I know when a new invoice is generated?",
            answer: """
                    You'll receive a push notification on your device whenever a new invoice is generated. Make sure notifications are enabled for the app in your device settings to receive these alerts.
                    """
        ),
        (
            question: "What happens if I miss a notification?",
            answer: """
                    Don't worry! You can always check your current invoices and dues in the app's dashboard, even if you miss a notification.
                    """
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Payments & Methods
                    Text("Payments & Methods")
                        .font(.custom("Montserrat-SemiBold", size: 18))
                        .padding(.top, 16) // <--- added spacing
                    ForEach(paymentRules[0...3], id: \.question) { rule in
                        ExpandableCard(question: rule.question, answer: rule.answer)
                    }
                    
                    // Tracking & History
                    Text("Tracking & History")
                        .font(.custom("Montserrat-SemiBold", size: 18))
                        .padding(.top, 16) // <--- added spacing
                    ForEach(paymentRules[4...7], id: \.question) { rule in
                        ExpandableCard(question: rule.question, answer: rule.answer)
                    }
                    
                    // Account Management
                    Text("Account Management")
                        .font(.custom("Montserrat-SemiBold", size: 18))
                        .padding(.top, 16) // <--- added spacing
                    ForEach(paymentRules[8...10], id: \.question) { rule in
                        ExpandableCard(question: rule.question, answer: rule.answer)
                    }
                    
                    // Invoices & Notifications
                    Text("Invoices & Notifications")
                        .font(.custom("Montserrat-SemiBold", size: 18))
                        .padding(.top, 16) // <--- added spacing
                    ForEach(paymentRules[11...12], id: \.question) { rule in
                        ExpandableCard(question: rule.question, answer: rule.answer)
                    }
                    
                    /*
                    // (Optional) If you want to keep the Contact Us card, just uncomment below:
                    ContactCard(phoneNumber: "9848574858",
                                email: "hello@proptoll.com")
                    */
                }
                .padding()
            }
            .background(.onMainTheme)
            .navigationTitle("FAQs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .imageScale(.large)
                    }
                }
            }
        }
    }
}

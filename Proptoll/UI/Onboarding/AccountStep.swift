import SwiftUI

struct AccountStep: View {
    @State private var isAnimated = false
    @State private var selectedTab = "statements"
    
    // Sample data
    let balance = 2450.00
    let dues = 150.00
    let statements = [
        (date: "24 Mar", title: "Monthly Rent", amount: -1200.00, type: "debit"),
        (date: "22 Mar", title: "Maintenance Fee", amount: -50.00, type: "debit"),
        (date: "20 Mar", title: "Security Deposit", amount: 3500.00, type: "credit")
    ]
    
    var body: some View {
        OnboardingStepView3(
            title: "Account",
            description: "With the Balance and Dues Feature in Proptoll, managing your finances is simple and transparent.",
            systemImage: "accountOB"
        ) {
            EmptyView()
        }
    }
}


import SwiftUI

struct InvoicesStep: View {
    @State private var isAnimated = false
    
    // Sample invoices
    let invoices = [
        (title: "Monthly Rent", amount: 1200.00, status: "Due", dueDate: "31 Mar"),
        (title: "Maintenance", amount: 50.00, status: "Paid", dueDate: "15 Mar"),
        (title: "Security Deposit", amount: 2400.00, status: "Paid", dueDate: "01 Mar")
    ]
    
    var body: some View {
        OnboardingStepView3(
            title: "Invoices",
            description: "Check Invocies and manage outstanding invoices.",
            systemImage: "invoiceOB"
        ) {
            EmptyView()
        }
    }
}

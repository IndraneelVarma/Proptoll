import SwiftUI

struct ReceiptsStep: View {
    @State private var isAnimated = false
    
    let receipts = [
        (title: "Monthly Rent", date: "25 Mar 2024", amount: 1200.00, id: "RCP-240325"),
        (title: "Maintenance Fee", date: "20 Mar 2024", amount: 50.00, id: "RCP-240320"),
        (title: "Parking Fee", date: "15 Mar 2024", amount: 100.00, id: "RCP-240315")
    ]
    
    var body: some View {
        OnboardingStepView3(
            title: "Receipts",
            description: "Automatically receive receipts for all your transactions.\nKeep your financial records organized.",
            systemImage: "receiptOB"
        ) {
            EmptyView()
        }
    }
}

import SwiftUI

struct ReceiptCardView: View {
    let receipt: Receipts
    @State private var showingDetailView = false
    @StateObject private var viewModel = ReceiptsViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    
    private var sortedReceivedTowards: String {
        receipt.receivedTowards
            .sorted { $0.amount ?? 0 > $1.amount ?? 0 }
            .map { $0.serviceName }
            .joined(separator: ", ")
    }
    
    var paymentModeColor: Color {
        let mode = receipt.payment?.modeOfPayment.capitalized ?? receipt.source.capitalized
        
        switch mode {
        case "Account":
            return .billPaid
        case "Net Banking":
            return .alert
        case "Cheque":
            return .blue
        case "Online":
            return .billDue
        case "Cash":
            return .green
        default:
            return .green
        }
    }
    
    private var customDivider: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.primary.opacity(0.25))
    }
    
    var body: some View {
        Button {
            showingDetailView = true
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    // Icon section
                    if #available(iOS 18, *) {
                        Image(systemName: receipt.source == "Account" ? "creditcard.fill" : "text.page.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .frame(width: 45, height: 45)
                            .background(
                                Circle()
                                    .fill(Color.plotBar)
                            )
                    }
                    else {
                        Image(systemName: receipt.source == "Account" ? "creditcard.fill" : "newspaper")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .frame(width: 45, height: 45)
                            .background(
                                Circle()
                                    .fill(Color.plotBar)
                            )
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Main content section
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Receipt \(receipt.receiptNumber)")
                                    .font(.custom("Montserrat-Medium", size: 16))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Text(sortedReceivedTowards)
                                    .font(.custom("Montserrat-Regular", size: 14))
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                            
                           
                            // Payment tag view with conditional styling
                            Text(receipt.payment?.modeOfPayment.capitalized ?? receipt.source.capitalized)
                                .font(.custom("Montserrat-Medium", size: 12))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(paymentModeColor.opacity(0.2))
                                .foregroundStyle(paymentModeColor)
                                .clipShape(Capsule())
                                
                                
                            
                        }
                        
                        // Date section
                        HStack(alignment: .center) {
                            Text("Paid on \(formatDateTime(receipt.createdAt))")
                                .font(.custom("Montserrat-Regular", size: 14))
                                .foregroundColor(.primary)
                            Spacer()
                            Text("₹\(Int(receipt.amountPaid))")
                                .font(.custom("Montserrat-Bold", size: 16))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(16)
            }
            .background(.cards)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .fullScreenCover(isPresented: $showingDetailView) {
            ReceiptDetailView(receipt: receipt, showingDetailView: $showingDetailView)
        }
    }
    
    private func formatDateTime(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = dateFormatter.date(from: dateString) else {
            return "Invalid date"
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMM yyyy, HH:mm"
        
        return outputFormatter.string(from: date)
    }
}

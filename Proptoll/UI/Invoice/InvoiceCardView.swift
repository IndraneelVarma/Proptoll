import SwiftUI

struct InvoiceCardView: View {
    // MARK: - Properties
    let invoice: Invoice
    @State private var showingDetailView = false
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var isPaid: Bool {
        invoice.isPaid ?? false
    }
    private var customDivider: some View {
        Rectangle()
            .frame(height: 1) // Increased from 0.25
            .foregroundColor(.primary.opacity(0.25))
    }
    // MARK: - Body
    var body: some View {
        Button(action: {
            matomoTracker.track(eventWithCategory: "invoice card",
                              action: "tapped",
                              name: "invoice id: \(invoice.id)",
                              url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
            showingDetailView = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Top section: Invoice Number and Status
                HStack {
                    Text("Invoice #\(String(invoice.invoiceNumber))")
                        .font(.custom("Montserrat-Regular", size: 16))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                   
                    Text("₹\(Int(invoice.totalAmount))")
                        .font(.custom("Montserrat-Bold", size: 16))
                        .foregroundColor(.primary)
                }
                
                // Bottom section: Dates and Amount
                HStack(alignment: .bottom) {
                    // Dates section
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text("Issued on: ")
                                .font(.custom("Montserrat-Regular", size: 12))
                                .foregroundColor(.primary)
                            Text(formatDate(invoice.issuedDate))
                                .font(.custom("Montserrat-Regular", size: 12))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                
                }
                
                customDivider
                
                HStack(alignment: .bottom){
                    HStack(spacing: 4) {
                        // Status Indicator
                        Text(isPaid ? "PAID" : "DUE")
                            .font(.custom("Montserrat-Regular", size: 12))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                isPaid ?
                                    Color.billPaid.opacity(0.15) :
                                    Color.billDue.opacity(0.15)
                            )
                            .foregroundColor(isPaid ? .billPaid : .billDue)
                            .clipShape(Capsule())
                        if !isPaid {
                            Text("on \(formatDate(invoice.dueDate))")
                                .font(.custom("Montserrat-Regular", size: 12))
                                .foregroundColor(.primary)
                                .padding(.leading, 4)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(.cards)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showingDetailView) {
            InvoiceDetailView(invoice: invoice, showingDetailView: $showingDetailView)
        }
    }
    
    // MARK: - Helper Methods
    func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = /*"yyyy-MM-dd"*/ "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = dateFormatter.date(from: dateString) else {
            return "Invalid date"
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMM yyyy"
        
        return outputFormatter.string(from: date)
    }
}

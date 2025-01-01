import SwiftUI

// MARK: - Main View
struct ReceiptDetailView: View {
    // MARK: - Properties
    let receipt: Receipts
    @Binding var showingDetailView: Bool
    @State private var pdfLoading = false
    @State private var showPdf = false
    @State private var expandedServices: Set<String> = []
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var viewModel = ReceiptsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ReceiptInfoCard(receipt: receipt)
                        
                        if !receipt.receivedTowards.isEmpty {
                            ReceivedTowardsCard(receivedTowards: receipt.receivedTowards)
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 20)
                }
                
                BottomActionBar(
                    receipt: receipt,
                    pdfLoading: $pdfLoading,
                    networkMonitor: networkMonitor,
                    viewModel: viewModel
                )
            }
            .background(Color(.systemGray6))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("#\(String(receipt.receiptNumber))")
            .navigationBarItems(
                leading: Button("Close") {
                    showingDetailView = false
                }
                .tint(.primary)
                .font(.custom("Montserrat-Medium", size: 16))
            )
            .onChange(of: viewModel.receiptUrl) { url in
                if url != nil {
                    pdfLoading = false
                    showPdf = true
                }
            }
            .fullScreenCover(isPresented: $showPdf) {
                PdfViewContainer(
                    receiptNumber: receipt.receiptNumber,
                    urlString: viewModel.receiptUrl?.URL ?? "",
                    showPdf: $showPdf
                )
            }
        }
    }
}

// MARK: - Receipt Info Card
private struct ReceiptInfoCard: View {
    let receipt: Receipts
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Receipt Details")
                .font(.custom("Montserrat-Medium", size: 18))
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 12) {
                Group {
                    DetailRow2(title: "Receipt No.", value: "#\(receipt.receiptNumber)")
                    DetailRow2(title: "Amount Paid", value: "₹\(String(format: "%.2f", receipt.amountPaid))")
                    DetailRow2(title: "Payment Mode", value: receipt.payment?.modeOfPayment.uppercased() ?? receipt.source)
                    if let payments = receipt.payment {
                        DetailRow2(title: "Collected By", value: payments.paymentTakenBy)
                        if payments.modeOfPayment == "Cheque" {
                            DetailRow2(title: "Cheque No.", value: payments.chequeNumber ?? "")
                        }
                        else {
                            if payments.referenceId ?? "" != "" {
                                DetailRow2(title: "Transaction No.", value: payments.referenceId ?? "")
                            }
                        }
                    }
                    DetailRow2(title: "Payment Date", value: formatDateTime(receipt.createdAt))
                }
                .font(.custom("Montserrat-Regular", size: 14))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Received Towards Card
private struct ReceivedTowardsCard: View {
    let receivedTowards: [ReceivedTowards]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Received Towards")
                .font(.custom("Montserrat-Medium", size: 18))
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(receivedTowards, id: \.serviceName) { item in
                DetailRow2(title: item.serviceName, value: "₹\(String(format: "%.2f", item.amount ?? 0))")
                    .font(.custom("Montserrat-Regular", size: 14))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Bottom Action Bar
private struct BottomActionBar: View {
    let receipt: Receipts
    @Binding var pdfLoading: Bool
    @ObservedObject var networkMonitor: NetworkMonitor
    @ObservedObject var viewModel: ReceiptsViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading) {
                Text("Amount Paid")
                    .font(.custom("Montserrat-Medium", size: 18))
                Text("₹\(String(format: "%.2f", receipt.amountPaid))")
                    .font(.custom("Montserrat-Bold", size: 20))
            }
            
            Spacer()
            
            DownloadButton(
                receipt: receipt,
                pdfLoading: $pdfLoading,
                networkMonitor: networkMonitor,
                viewModel: viewModel
            )
        }
        .padding(20)
    }
}

// MARK: - Download Button
private struct DownloadButton: View {
    let receipt: Receipts
    @Binding var pdfLoading: Bool
    @ObservedObject var networkMonitor: NetworkMonitor
    @ObservedObject var viewModel: ReceiptsViewModel
    
    var body: some View {
        Button(action: {
            matomoTracker.track(eventWithCategory: "download receipts",
                              action: "tapped",
                              url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
            pdfLoading = true
            Task {
                await viewModel.downloadReceipt(jsonQuery: [:], receiptId: receipt.receiptNumber)
            }
        }) {
            if !pdfLoading {
                Text("Download")
                    .font(.custom("Montserrat-Medium", size: 16))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 35)
                            .foregroundStyle(
                                networkMonitor.isConnected
                                ? LinearGradient(
                                    colors: [Color("lavender500"), Color("BluePurple")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                : LinearGradient(
                                    colors: [.gray, .gray],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            } else {
                CustomProgressView(color: .blue, lineWidth: 1, size: 20, duration: 1)
            }
        }
        .disabled(!networkMonitor.isConnected)
    }
}

// MARK: - PDF View Container
private struct PdfViewContainer: View {
    let receiptNumber: String
    let urlString: String
    @Binding var showPdf: Bool
    
    var body: some View {
        NavigationStack {
            PdfView(urlString: urlString, showPdf: $showPdf)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            if let url = URL(string: urlString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .tint(.blue)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            matomoTracker.track(eventWithCategory: "pdf view back button", action: "taped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                            showPdf = false
                        } label: {
                            Image(systemName: "arrow.left")
                        }
                        .tint(.blue)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Text("PropToll_receipt_\(receiptNumber)")
                            .font(.custom("Montserrat-Regular", size: 16))
                    }
                }
        }
    }
}

// MARK: - Detail Row Component
struct DetailRow2: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
        .font(.custom("Montserrat-Regular", size: 14))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Helper Functions
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

private extension ReceiptDetailView {
    func toggleService(_ service: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if expandedServices.contains(service) {
                expandedServices.remove(service)
            } else {
                expandedServices.insert(service)
            }
        }
    }
}

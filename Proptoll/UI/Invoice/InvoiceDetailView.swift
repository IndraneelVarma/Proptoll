import SwiftUI

// MARK: - Main View
struct InvoiceDetailView: View {
    // MARK: - Properties
    let invoice: Invoice
    @Binding var showingDetailView: Bool
    @State private var expandedServices: Set<String> = []  // Will initialize with all IDs in onAppear
    @State private var pdfLoading = false
    @State private var showPdf = false
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var viewModel = InvoiceViewModel()
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                mainScrollContent
                totalSection
            }
            .background(Color(.systemGray6))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("#\(String(invoice.invoiceNumber))")
            .navigationBarItems(leading: closeButton)
            .onChange(of: viewModel.invoiceUrl) { url in
                if url != nil {
                    pdfLoading = false
                    showPdf = true
                }
            }
            .onAppear {
                // Expand all services by default
                if let items = invoice.invoiceItems {
                    expandedServices = Set(items.map { $0.id })
                }
            }
            .fullScreenCover(isPresented: $showPdf) {
                pdfViewNavigationStack
            }
        }
    }
    
    // MARK: - View Components
    private var mainScrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                invoiceDetailsCard
                servicesSection
                Divider()
                    .padding(.vertical, 8)
                    .padding(.horizontal)
            }
            .padding(.vertical, 20)
        }
    }
    
    private var invoiceDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Invoice Details")
                .font(.custom("Montserrat-Medium", size: 18))
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 12) {
                Group {
                    DetailRow(title: "Invoice To", value: invoice.invoiceTo)
                    DetailRow(title: "Month", value: "\(invoice.invoiceMonth) \(invoice.invoiceYear)")
                    DetailRow(title: "Issued Date", value: formatSimpleDate(invoice.issuedDate))
                    if !(invoice.isPaid ?? false) {
                        DetailRow(title: "Due Date", value: formatSimpleDate(invoice.dueDate))
                    }
                    DetailRow(title: "Status", value: "\(invoice.isPaid ?? false ? "Paid" : "Due")")
                    DetailRow(title: "Invoice No.", value: "\(invoice.invoiceNumber)")
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
    
    private var servicesSection: some View {
        Group {
            if let items = invoice.invoiceItems, !items.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Services")
                        .font(.custom("Montserrat-Medium", size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ForEach(items) { item in
                        ServiceItemView(
                            item: item,
                            isExpanded: expandedServices.contains(item.id),
                            onTap: { toggleService(item.id) }
                        )
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var totalSection: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading) {
                Text("Total Payable")
                    .font(.custom("Montserrat-Medium", size: 18))
                Text("₹\(String(format: "%.2f", invoice.totalAmount))")
                    .font(.custom("Montserrat-Bold", size: 20))
            }
            
            Spacer()
            
            downloadButton
        }
        .padding(20)
    }
    
    private var downloadButton: some View {
        Button(action: {
            matomoTracker.track(eventWithCategory: "download invoice",
                              action: "tapped",
                              url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
            pdfLoading = true
            Task {
                await viewModel.downloadInvoice(jsonQuery: [:], invoiceId: invoice.id)
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
    
    private var closeButton: some View {
        Button("Close") {
            showingDetailView = false
        }
        .tint(.primary)
        .font(.custom("Montserrat-Medium", size: 16))
    }
    
    private var pdfViewNavigationStack: some View {
        NavigationStack {
            PdfView(urlString: viewModel.invoiceUrl?.URL ?? "", showPdf: $showPdf)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            if let url = URL(string: viewModel.invoiceUrl?.URL ?? "") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .tint(.blue)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            matomoTracker.track(eventWithCategory: "pdf view back button",
                                              action: "taped",
                                              url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                            showPdf = false
                        } label: {
                            Image(systemName: "arrow.left")
                        }
                        .tint(.blue)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Text("PropToll_invoice_\(invoice.invoiceNumber)")
                            .font(.custom("Montserrat-Regular", size: 16))
                    }
                }
        }
    }
    
    // MARK: - Helper Methods
    private func toggleService(_ id: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if expandedServices.contains(id) {
                expandedServices.remove(id)
            } else {
                expandedServices.insert(id)
            }
        }
    }
    
    private func formatSimpleDate(_ dateString: String) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            guard let date = dateFormatter.date(from: dateString) else { return "Invalid date" }
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd MMM yyyy"
            return outputFormatter.string(from: date)
        }
}

// MARK: - Supporting Views
struct ServiceItemView: View {
    // MARK: - Properties
    let item: InvoiceItems
    let isExpanded: Bool
    let onTap: () -> Void
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onTap) {
                HStack {
                    Text(item.serviceName ?? "")
                        .font(.custom("Montserrat-Medium", size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if !isExpanded {
                        Text("₹\(String(format: "%.2f", item.totalAmount ?? 0))")
                            .font(.custom("Montserrat-Medium", size: 14))
                    }
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .imageScale(.small)
                }
            }
            .foregroundColor(.primary)
            .padding(.vertical, 4)
            
            if isExpanded {
                expandedContent
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Supporting Views
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            if item.serviceName != "LateCharges" && item.serviceName != "lateCharges" {
                if item.serviceName == "Water" {
                    DetailRow(title: "Previous Reading", value: "\(item.previousReading ?? 0)")
                    DetailRow(title: "Present Reading", value: "\(item.presentReading ?? 0)")
                }
                
                DetailRow(title: "Gross", value: "₹\(String(format: "%.2f",(item.totalAmount ?? 0) + (item.discount ?? 0)))")
                DetailRow(title: "Discount", value: "₹\(String(format: "%.2f",(item.discount ?? 0)))")
            }
            DetailRow(title: "Total", value: "₹\(String(format: "%.2f",item.totalAmount ?? 0))")
        }
        .padding(.top, 8)
        .transition(.opacity)
    }
}

struct DetailRow: View {
    // MARK: - Properties
    let title: String
    let value: String
    
    // MARK: - Body
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .foregroundColor(title == "Total" ? .primary : .secondary)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .multilineTextAlignment(.leading)
        }
        .font(.custom(title == "Total" ? "Montserrat-SemiBold" : "Montserrat-Regular", size: 14))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

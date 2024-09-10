import SwiftUI
import PDFKit

struct BillsCardView: View {
    @State private var isExpanded = false
    let bill: Bill?
    @StateObject var viewModel = BillsViewModel()
    @State var pdfLoading = false
    @State var showPdf = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            
            if isExpanded {
                VStack(spacing: 16) {
                    billDetailsTable
                    
                    additionalInfoView
                    
                    Button(action: {
                        Task {
                            matomoTracker.track(eventWithCategory:"download bill", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                            await viewModel.downloadBills(jsonQuery:[:], billId2:bill?.id ?? "")
                            pdfLoading = true
                        }
                    }, label: {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(pdfLoading ? .gray : .purple)
                            .frame(width: 300,height: 50)
                            .overlay {
                                if pdfLoading {
                                    HStack {
                                        Text("Loading...")
                                            .foregroundStyle(.white)
                                        ProgressView()
                                    }
                                } else {
                                    Text("Download Bill")
                                        .foregroundStyle(.white)
                                }
                            }
                    })
                }
                .onChange(of: viewModel.billUrl) { oldValue, newValue in
                    showPdf = true
                    pdfLoading = false
                }
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
                
            }
        }
        .background(Color(UIColor.systemGray4))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .animation(.spring(), value: isExpanded)
        .fullScreenCover(isPresented: $showPdf) {
            NavigationStack {
                PdfView(urlString: viewModel.billUrl?.URL ?? "")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                if let url = URL(string: viewModel.billUrl?.URL ?? "") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                        ToolbarItem(placement: .navigationBarLeading){
                            Button("Back") {
                                matomoTracker.track(eventWithCategory: "pdf view back button", action: "taped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                                showPdf = false
                            }
                        }
                    }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading){
                Text(bill?.billMonth ?? "No Month")
                    .font(.headline)
                
                Text("Issued on \(formatDate(bill?.createdAt ?? ""))")
                    
            }
            
            Spacer()
            
            Text(bill?.isPaymentDone ?? true ? "Paid" : "Due")
                .font(.subheadline)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(bill?.isPaymentDone ?? true ? Color.green : Color.red)
                .foregroundColor(.white)
                .clipShape(Capsule())
            
            Image(systemName: "chevron.right")
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .animation(.spring(), value: isExpanded)
        }
        .padding()
        .background(Color(UIColor.systemGray4))
        .onTapGesture {
            if isExpanded{
                matomoTracker.track(eventWithCategory: "bill dropdown button", action: "contracted", name: "bill id: \(bill?.id ?? "")", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
            }
            else
            {
                matomoTracker.track(eventWithCategory: "bill dropdown button", action: "expanded", name: "bill id: \(bill?.id ?? "")", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
            }
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
    
    private var billDetailsTable: some View {
        let items = [
            "Type", "Water", "Maint.", "Security",
            "Balance", "₹\((bill?.waterOpeningBalance ?? 202))",
            "₹\((bill?.maintenanceOpeningBalance ?? 202) )",
            "₹\((bill?.securityOpeningBalance ?? 202))",
            "Gross", "₹\(bill?.grossWaterCharges ?? 404)", "₹\(bill?.grossMaintenanceCharges ?? 404)", "₹\(bill?.grossSecurityCharges ?? 404)",
            "20KL", "₹\(bill?._20kl ?? 404)", "-", "-",
            "ADF", "₹\(bill?.adfWater ?? 404)", "₹\(bill?.adfMaintenance ?? 404)", "₹\(bill?.adfSecurity ?? 404)",
            "Total", "₹\(bill?.totalWaterCharges ?? 404)", "₹\(bill?.totalMaintenanceCharges ?? 404)", "₹\(bill?.totalSecurityCharges ?? 404)"
        ]
        
        return ProfessionalTableView(items: items, rowCount: 6, columnCount: 4)
    }
    func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = dateFormatter.date(from: dateString) else {
            return "Invalid date"
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMMM"
        
        return outputFormatter.string(from: date)
    }
    
    private var additionalInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            InfoRow(title: "Bill Number", value: "\(bill?.billNumber ?? "404")")
            InfoRow(title: "Units Billed", value: "\(bill?.unitsConsumed ?? 404)")
            InfoRow(title: "Late Charges", value: "₹\(bill?.lateCharges ?? 404)")
            InfoRow(title: "Total Payable", value: "₹\(bill?.totalPayable ?? 404)")
            
            if !(bill?.isPaymentDone ?? false) {
                var formattedDate: String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    if let date = dateFormatter.date(from: bill?.dueDate ?? "404") {
                        dateFormatter.dateFormat = "d MMMM yyyy"
                        return dateFormatter.string(from: date)
                    } else {
                        return "Invalid date"
                    }
                }
                InfoRow(title: "Due Date", value: formattedDate)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    BillsCardView(bill: nil)
}

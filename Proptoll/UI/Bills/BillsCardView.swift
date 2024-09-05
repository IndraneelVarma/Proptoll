import SwiftUI
import PDFKit

struct BillsCardView: View {
    @State private var isExpanded = false
    let bill: Bill?
    @StateObject var viewModel = BillsViewModel()
    @State var showPdf = false
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading, spacing: 0) {
                headerView
                
                if isExpanded {
                    VStack(spacing: 16) {
                        billDetailsTable
                        additionalInfoView
                        Button(action: {
                            if ((viewModel.billUrl?.URL.isEmpty) == false)
                            {
                                
                                showPdf = true
                            }
                            print(showPdf)
                        }, label: {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.purple)
                                .frame(width: 300,height: 50)
                                .overlay{
                                    Text("Download PDF")
                                        .foregroundStyle(.white)
                                }
                        })
                        .navigationDestination(isPresented: $showPdf) {
                            PdfView(urlString: viewModel.billUrl?.URL ?? "")
                                .navigationBarItems(trailing:
                                 Button(action: {
                                    if let url = URL(string:viewModel.billUrl?.URL ?? "") {
                                            UIApplication.shared.open(url)
                                        }
                                }) {
                                    Image(systemName: "square.and.arrow.up")
                                }
                                )
                        }
                    }
                    .onAppear(){
                        Task{
                            await viewModel.downloadBills(jsonQuery:[:], billId2:bill?.id ?? "")
                        }
                    }
                    
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .background(Color(UIColor.systemGray4))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            //.shadow(radius: 5)
            .animation(.spring(), value: isExpanded)
        }
    }
    
    private var headerView: some View {
        HStack {
            Text(bill?.billMonth ?? "No Month")
                .font(.headline)
            
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
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
    
    private var billDetailsTable: some View {
        let items = [
            "Type", "Water", "Maint.", "Security",
            "Balance", "₹\((bill?.waterOpeningBalance ?? 202) + (bill?.waterClosingBalance ?? 202))",
            "₹\((bill?.maintenanceOpeningBalance ?? 202) + (bill?.maintenanceClosingBalance ?? 202))",
            "₹\((bill?.securityOpeningBalance ?? 202) + (bill?.securityClosingBalance ?? 202))",
            "Gross", "₹\(bill?.grossWaterCharges ?? 404)", "₹\(bill?.grossMaintenanceCharges ?? 404)", "₹\(bill?.grossSecurityCharges ?? 404)",
            "20KL", "₹\(bill?._20kl ?? 404)", "-", "-",
            "ADF", "₹\(bill?.adfWater ?? 404)", "₹\(bill?.adfMaintenance ?? 404)", "₹\(bill?.adfSecurity ?? 404)",
            "Total", "₹\(bill?.totalWaterCharges ?? 404)", "₹\(bill?.totalMaintenanceCharges ?? 404)", "₹\(bill?.totalSecurityCharges ?? 404)"
        ]
        
        return ProfessionalTableView(items: items, rowCount: 6, columnCount: 4)
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
                        dateFormatter.dateFormat = "d MMM yyyy"
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

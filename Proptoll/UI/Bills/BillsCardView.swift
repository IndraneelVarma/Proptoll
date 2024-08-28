import SwiftUI

struct BillsCardView: View {
    @State private var isExpanded = false
    let bill: Bill?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            
            if isExpanded {
                VStack(spacing: 16) {
                    billDetailsTable
                    additionalInfoView
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
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    
                    if let date = dateFormatter.date(from: bill?.dueDate ?? "404") {
                        dateFormatter.dateFormat = "d MMM yyyy, hh:mm a"
                        dateFormatter.amSymbol = "AM"
                        dateFormatter.pmSymbol = "PM"
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

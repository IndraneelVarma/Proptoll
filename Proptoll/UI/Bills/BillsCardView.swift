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
        .background(Color(UIColor.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 5)
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
            "Balance", "\((bill?.waterOpeningBalance ?? 202) + (bill?.waterClosingBalance ?? 202))",
            "\((bill?.maintenanceOpeningBalance ?? 202) + (bill?.maintenanceClosingBalance ?? 202))",
            "\((bill?.securityOpeningBalance ?? 202) + (bill?.securityClosingBalance ?? 202))",
            "20KL", "\(bill?._20kl ?? 404)", "-", "-",
            "ADF", "\(bill?.adfWater ?? 404)", "\(bill?.adfMaintenance ?? 404)", "\(bill?.adfSecurity ?? 404)",
            "Total", "", "", ""
        ]
        
        return ProfessionalTableView(items: items, rowCount: 5, columnCount: 4)
    }
    
    private var additionalInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            InfoRow(title: "Bill Number", value: "\(bill?.billNumber ?? "404")")
            InfoRow(title: "Units Billed", value: "\(bill?.unitsConsumed ?? 404)")
            InfoRow(title: "Late Charges", value: "\(bill?.lateCharges ?? 404)")
            InfoRow(title: "Total Payable", value: "\(bill?.dueAmount ?? 404)")
            
            if !(bill?.isPaymentDone ?? false) {
                InfoRow(title: "Due Date", value: bill?.dueDate ?? "404")
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}

struct ProfessionalTableView: View {
    let items: [String]
    let rowCount: Int
    let columnCount: Int
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<rowCount, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<columnCount, id: \.self) { column in
                        let index = row * columnCount + column
                        if index < items.count {
                            CellView(text: items[index], isHeader: row == 0)
                        } else {
                            CellView(text: "", isHeader: false)
                        }
                    }
                }
            }
        }
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct CellView: View {
    let text: String
    let isHeader: Bool
    
    var body: some View {
        Text(text)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, minHeight: 30, alignment: .trailing)
            .background(isHeader ? Color(UIColor.systemGray4) : Color(UIColor.systemBackground))
            .foregroundColor(isHeader ? .primary : .secondary)
            .font(.system(size: 12, weight: isHeader ? .semibold : .regular))
            .overlay(
                Rectangle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            )
    }
}

#Preview {
    BillsCardView(bill: nil)
}

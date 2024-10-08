import SwiftUI

struct ReceiptsCardViewSecondary: View {
    @State private var isExpanded = false
    let receipt: Receipts?
    let bill: Bill?
    @State private var pdfLoading = false
    @Binding var paid: Int
    @State var showPdf = false
    @StateObject var viewModel = ReceiptsViewModel()
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: receipt?.paymentDate ?? "") {
            dateFormatter.dateFormat = "d MMM yyyy, hh:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            return dateFormatter.string(from: date)
        } else {
            return "Invalid date"
        }
    }
    
    var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                headerView
                
                if isExpanded {
                    VStack(spacing: 16) {
                        billDetailsTable
                        
                        additionalInfoView
                        
                        Button(action: {
                            Task{
                                await viewModel.downloadReceipts(jsonQuery:[:], receiptId: receipt?.id ?? "")
                                pdfLoading = true
                            }
                        }, label: {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(pdfLoading ? .gray : .purple)
                                .frame(width: 300,height: 50)
                                .overlay{
                                    if pdfLoading
                                    {
                                        HStack{
                                            Text("Loading...")
                                                .foregroundStyle(.white)
                                            ProgressView()
                                        }
                                    }
                                    else
                                    {
                                        Text("Download Receipt")
                                            .foregroundStyle(.white)
                                    }
                                }
                        })
                        .fullScreenCover(isPresented: $showPdf) {
                            NavigationStack{
                                PdfView(urlString: viewModel.receiptUrl?.URL ?? "")
                                    .toolbar {
                                        ToolbarItem(placement: .navigationBarTrailing) {
                                            Button(action: {
                                                if let url = URL(string: viewModel.receiptUrl?.URL ?? "") {
                                                    UIApplication.shared.open(url)
                                                }
                                            }) {
                                                Image(systemName: "square.and.arrow.up")
                                            }
                                        }
                                        ToolbarItem(placement: .navigationBarLeading){
                                            Button("Back") {
                                                showPdf = false
                                            }
                                        }
                                    }
                            }
                        }
                    }
                    .onChange(of: viewModel.receiptUrl, { oldValue, newValue in
                        showPdf = true
                        pdfLoading = false
                    })
                    
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                }
            }
            .onAppear(){
                paid += receipt?.amountPaid ?? 0
            }
            .background(Color(UIColor.systemGray4))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            //.shadow(radius: 5)
            .animation(.spring(), value: isExpanded)
        }
    
    
    private var headerView: some View {
        HStack {
            VStack{
                Text("Receipt \(receipt?.receiptNumber ?? 404)")
                    .font(.headline)
                Text("\(formattedDate)")
            }
            
            Spacer()
            
            VStack{
                Text(receipt?.modeOfPayment == "Unified Payments" ? "UPI" : "Cash")
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(receipt?.modeOfPayment == "Unified Payments" ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                Text("Paid ₹\(receipt?.amountPaid ?? 404)")
            }
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
            "Water", "Maintenance", "Security", "Overdue",
            "\(receipt?.receivedTowardsWater ?? 404)", "\(receipt?.receivedTowardsMaintenance ?? 404)", "\(receipt?.receivedTowardsSecurity ?? 404)", "-"
        ]
        
        return ProfessionalTableView(items: items, rowCount: 3, columnCount: 4)
    }
    
    private var additionalInfoView: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            InfoRow(title: "Receipt No.", value: "\(receipt?.receiptNumber ?? 404)")
            InfoRow(title: "Bill No.", value: "\(receipt?.billId ?? "404")")
            InfoRow(title: "Due/Credit Amount", value: "\(bill?.dueAmount ?? 404)") //do post lunch
            InfoRow(title: "Paid On", value: formattedDate)
            InfoRow(title: "Paid By", value: "\(receipt?.modeOfPayment ?? "no method")")
            
            
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    ReceiptsCardViewSecondary(receipt: nil, bill: nil, paid: .constant(0))
}




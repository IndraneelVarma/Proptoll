import SwiftUI

struct ReceiptsCardViewMain: View {
    @State private var isExpanded = false
    @StateObject var viewModel = ReceiptsViewModel()
    let bill: Bill?
    @Binding var totalPaid: Int
    @State private var count = 0
   @State var c = 0
    @State private var decoyPaid = 0
    @State private var paid = 0 //ive put paid = 0 all over the code to prevent its value from doubling again and again when repeatedly calling SecondaryCardView
    @State private var showProgress = true
    var body: some View {

            VStack(alignment: .leading, spacing: 0) {
                headerView
                
                if isExpanded {
                    VStack(spacing: 16) {
                        if(viewModel.receipts.isEmpty)
                        {
                            VStack {
                                if showProgress {
                                    ProgressView()
                                } else {
                                    Text("No results found")
                                }
                            }
                            .onAppear {
                                showProgress = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                    showProgress = false
                                }
                            }
                        }
                        else
                        {
                            ForEach(viewModel.receipts, id: \.self){ receipt in
                                ReceiptsCardViewSecondary(receipt: receipt, bill: bill, paid: $decoyPaid)
                            }
                        }
                    }
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                else
                {
                    if(!viewModel.receipts.isEmpty)
                    {//we shall render an empty card to calculate paid amt before expanding
                        ForEach(viewModel.receipts, id: \.self){ receipt in
                            ReceiptsCardViewSecondary(receipt: receipt, bill: bill, paid: $paid)
                                .frame(width: 0, height: 0)
                                .hidden()
                                .accessibility(hidden: true)
                                .onAppear(){
                                    if(c <= (bill?.payments?.count ?? 1)-1)
                                    {
                                        totalPaid += receipt.amountPaid ?? 0
                                        c += 1
                                    }
                                }
                        }
                        
                    }
                }
            }
            .onChange(of: paid, { oldValue, newValue in
                count += 1
                if(paid != 0 && count == 2)
                {
                    count = 0
                    paid/=2
                }
            })
            .onAppear(){
                paid = 0
                Task{
                    await viewModel.fetchReceipts(jsonQuery:["filter[where][bill_id]": "\(bill?.id ?? "")"])
                }
            }
            .background(Color(UIColor.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            //.shadow(radius: 5)
            .animation(.spring(), value: isExpanded)
        }
    
    private var headerView: some View {
        HStack {
            Text(bill?.billMonth ?? "no month")
                .font(.headline)
            
            Spacer()
            
            Text("₹\(paid)")
            Image(systemName: "chevron.right")
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .animation(.spring(), value: isExpanded)
        }
        
        .padding()
        .background(Color(UIColor.systemGray5))
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
}





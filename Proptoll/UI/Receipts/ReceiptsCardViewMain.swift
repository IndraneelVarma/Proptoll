import SwiftUI

struct ReceiptsCardViewMain: View {
    @State private var isExpanded = false
    @StateObject var viewModel = ReceiptsViewModel()
    let bill: Bill?
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
                            ReceiptsCardViewSecondary(receipt: receipt)
                        }
                    }
                }
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear(){
            Task{
                await viewModel.fetchReceipts(jsonQuery:["filter[where][bill_id]": "\(bill?.id ?? "")"])
            }
        }
        .background(Color(UIColor.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 5)
        .animation(.spring(), value: isExpanded)
    }
    
    private var headerView: some View {
        HStack {
            Text(bill?.billMonth ?? "no month")
                .font(.headline)
            
            Spacer()
           
            Text("\(bill?.dueAmount ?? 404)")
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
}


#Preview {
    ReceiptsCardViewMain(bill: nil)
}


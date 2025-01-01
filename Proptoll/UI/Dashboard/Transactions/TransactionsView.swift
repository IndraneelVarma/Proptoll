import SwiftUI

struct TransactionsView: View {
    @State private var selectedFilter: String = "All"
    @Binding var showTrans: Bool
    let transactions: [Transaction]
    @Binding var year: String
    @StateObject private var userDefaultsMonitor = UserDefaultsMonitor()
    @StateObject private var networkMonitor = NetworkMonitor()
    private let filterOptions = ["All", "Credit", "Debit"]
    
    var body: some View {
        VStack(spacing: 10) {
            // Filter buttons
            HStack {
                Text("All Activity")
                    .font(.custom("Montserrat-Regular", size: 16))
                
                Spacer()
            }
            
            // Transactions list or Empty State
            if transactions.isEmpty {
                EmptyTransactionsView(isConnected: networkMonitor.isConnected)
                    .padding(.top, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(transactions, id: \.id) { transaction in
                        TransactionCardView(transaction: transaction)
                    }
                }
                .padding(.top, 2.5)
            }
        }
        .navigationTitle("Transactions")
        .navigationBarItems(leading: Button("Close") {
            showTrans = false
        })
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal)
        .padding(.top)
    }
    
    // Dummy function to represent fetching transactions
    private func fetchTransactions() {
        // Implement your data fetching logic here
    }
}

struct EmptyTransactionsView: View {
    let isConnected: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Illustration/Image
            Image(systemName: isConnected ? "list.bullet" : "wifi.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            // Descriptive Text
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
        .padding(.top, 40)
    }
    
    private var message: String {
        isConnected ?
            "No transactions found." :
            "Unable to fetch transactions.\nPlease check your internet connection."
    }
}

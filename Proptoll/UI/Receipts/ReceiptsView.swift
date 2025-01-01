import SwiftUI
import Sentry
import AVKit

struct ReceiptsView: View {
    // MARK: - Properties
    @StateObject private var viewModel = ReceiptsViewModel()
    @StateObject private var userDefaultsMonitor = UserDefaultsMonitor()
    @StateObject private var networkMonitor = NetworkMonitor()
    
    // MARK: - State Variables
    @State private var showSheet = false
    @State private var year: String = String(Calendar.current.component(.year, from: Date()))
    @State private var showingSettings = false
    @State private var showProgress = true
    @State private var showText = true
    @State private var count = 0
    
    private var nextYear: String {
        if let currentYear = Int(year) {
            return String(currentYear + 1)
        }
        return String(Calendar.current.component(.year, from: Date()) + 1)
    }
    
    // MARK: - Computed Properties
    private var totalPaid: Int {
        viewModel.receipts.reduce(0) { total, receipt in
            if let payment = receipt.payment {
                return total + (Int(payment.amountPaid) ?? 0)
            }
            return total
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    headerView(geometry: geometry)
                    mainContent
                }
                .frame(width: geometry.size.width)
            }
        }
        .tint(.white)
        .navigationDestination(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView(showSettings: $showingSettings)
            }
        }
        .onAppear(perform: handleOnAppear)
        .onChange(of: networkMonitor.isConnected) { _ in
            if networkMonitor.isConnected {
                fetchReceipts()
            }
        }
        .onChange(of: userDefaultsMonitor.selectedAccountId, perform: handleUnitChange)
        .onChange(of: viewModel.receipts, perform: handleInvoicesChange)
        .onChange(of: year, perform: handleYearChange)
    }
    
    // MARK: - Header View
    private func headerView(geometry: GeometryProxy) -> some View {
        ZStack {
            Color(.mainTheme)
                .frame(height: geometry.safeAreaInsets.top)
                .ignoresSafeArea(.all)
            
            HStack(alignment: .center) {
                Image(.proptollIconNoname)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 35)
                    .foregroundStyle(.orange)
                
                Text("Receipts")
                    .font(.custom("Montserrat-Bold", size: 22))
                    .foregroundColor(.specialText)
                
                Spacer()
                
                profileButton
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Profile Button
    private var profileButton: some View {
        Button(action: {
            showingSettings = true
            // Matomo event: user tapped profile button
            matomoTracker.track(
                eventWithCategory: "ReceiptsView",
                action: "profile button tapped",
                url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
            )
        }) {
            InitialProfileImage(
                username: UserDefaults.standard.string(forKey: "mainName") ?? "",
                size: 30,
                backgroundColor: .specialText,
                textColor: .onMainTheme
            )
        }
        .foregroundStyle(.specialText)
        .padding(.horizontal)
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            // If you have a custom top bar, place it here
            // TopBarView()
            
            // (Uncomment these if you decide to show total paid again)
            // totalPaidSection
            // divider
            
            yearFilterSection
            contentSection
        }
    }
    
    // MARK: - Total Paid Section (commented out in original)
    private var totalPaidSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("Total Paid")
                    .padding(.top, 10)
                
                Text("₹ \(totalPaid)")
                    .bold()
                    .font(.title2)
            }
            .padding(.horizontal)
            Spacer()
        }
    }
    
    // MARK: - Divider (commented out in original)
    private var divider: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10)
        }
        .frame(maxWidth: .infinity, maxHeight: 2)
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
    }
    
    // MARK: - Year Filter Section
    private var yearFilterSection: some View {
        HStack {
            Spacer()
            yearFilterMenu
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
    
    private var yearFilterMenu: some View {
        Menu {
            Button(action: {
                matomoTracker.track(
                    eventWithCategory: "year filter",
                    action: "set to \(String(Calendar.current.component(.year, from: Date())))",
                    url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
                )
                year = String(Calendar.current.component(.year, from: Date()))
            }) {
                Text(String(Calendar.current.component(.year, from: Date())))
            }
            
            Button(action: {
                matomoTracker.track(
                    eventWithCategory: "year filter",
                    action: "set to \(String(Calendar.current.component(.year, from: Date()) - 1))",
                    url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
                )
                year = String(Calendar.current.component(.year, from: Date()) - 1)
            }) {
                Text(String(Calendar.current.component(.year, from: Date()) - 1))
            }
            
            Button(action: {
                matomoTracker.track(
                    eventWithCategory: "year filter",
                    action: "set to \(String(Calendar.current.component(.year, from: Date()) - 2))",
                    url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
                )
                year = String(Calendar.current.component(.year, from: Date()) - 2)
            }) {
                Text(String(Calendar.current.component(.year, from: Date()) - 2))
            }
        } label: {
            HStack(spacing: 4) {
                Text("\(year)")
                    .font(.custom("Montserrat-Regular", size: 15))
                    .foregroundStyle(.specialText)
                Image(systemName: "chevron.down")
                    .font(.system(size: 15))
                    .foregroundStyle(.specialText)
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.plotBar)
            )
        }
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        receiptListView
    }
    
    private var receiptListView: some View {
        ScrollView(showsIndicators: false) {
            if !viewModel.receipts.isEmpty {
                LazyVStack {
                    ForEach(viewModel.receipts, id: \.id) { receipt in
                        ReceiptCardView(receipt: receipt)
                            .onTapGesture {
                                // Matomo event: user tapped a specific receipt card
                                matomoTracker.track(
                                    eventWithCategory: "ReceiptsView",
                                    action: "tapped receipt: \(receipt.id)",
                                    url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
                                )
                            }
                    }
                }
            } else {
                noReceiptsView
            }
        }
    }
    
    private var noReceiptsView: some View {
        Group {
            if showProgress {
                ProgressView()
                    .tint(.primary)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showProgress = false
                        }
                    }
            } else {
                // Matomo event: no receipts found displayed
                EmptyReceiptsView(isConnected: networkMonitor.isConnected)
                    .onAppear {
                        matomoTracker.track(
                            eventWithCategory: "ReceiptsView",
                            action: "no receipts displayed",
                            url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
                        )
                    }
            }
        }
    }
    
    private struct EmptyReceiptsView: View {
        let isConnected: Bool
        
        var body: some View {
            VStack(spacing: 20) {
                // Illustration/Image
                Image(systemName: isConnected ? "doc.text.magnifyingglass" : "wifi.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .accessibilityLabel(isConnected ? "No invoices available" : "No internet connection")
                
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
            isConnected
                ? "No receipts found."
                : "Unable to fetch receipts.\nPlease check your internet connection."
        }
    }
    
    // MARK: - Helper Methods
    private func selectYear(_ selectedYear: String) {
        matomoTracker.track(
            eventWithCategory: "year filter",
            action: "set to \(selectedYear)",
            url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
        )
        year = selectedYear
    }
    
    private func fetchReceipts() {
        Task {
            // Matomo event: fetchReceipts triggered
            matomoTracker.track(
                eventWithCategory: "ReceiptsView",
                action: "fetchReceipts called",
                url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
            )
            
            await viewModel.fetchReceipts(jsonQuery: [
                "filter[where][accountId]": userDefaultsMonitor.selectedAccountId,
                "filter[include][0][relation]": "payment",
                "filter[order]": "createdAt DESC",
                "filter[where][and][0][createdAt][gte]": year,
                "filter[where][and][1][createdAt][lt]": nextYear,
            ])
        }
    }
    
    // MARK: - Event Handlers
    private func handleOnAppear() {
        matomoTracker.track(view: ["Receipts Page"])
        showProgress = true
        count = 0
        if UserDefaults.standard.bool(forKey: "paymentStatus") {
            viewModel.receipts.removeAll()
            UserDefaults.standard.set(false, forKey: "paymentStatus")
        }
        // Matomo event: ReceiptsView appeared
        matomoTracker.track(view: ["Receipts Page"])
        
        fetchReceipts()
    }
    
    private func handleUnitChange(_ _: Any) {
        showProgress = true
        viewModel.receipts.removeAll()
        fetchReceipts()
    }
    
    private func handleInvoicesChange(_ _: Any) {
        count = viewModel.receipts.count
        if count > 0 {
            showProgress = false
        }
    }
    
    private func handleYearChange(_ _: String) {
        showProgress = true
        fetchReceipts()
    }
    
    func retry() {
        fetchReceipts()
        showProgress = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showProgress = false
        }
    }
}

// MARK: - Preview
#Preview {
    ReceiptsView()
}

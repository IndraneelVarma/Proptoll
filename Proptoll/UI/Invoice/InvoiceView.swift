import SwiftUI

struct InvoiceView: View {
    @State private var showingSettings = false
    @State private var showProgress = true
    @State private var isDuePage = true
    @State private var isPaid = ""
    @State private var year: String = String(Calendar.current.component(.year, from: Date()))
    
    @StateObject private var paymentState = PaymentStateModel()
    @StateObject private var viewModel = InvoiceViewModel()
    @StateObject private var viewModel2 = AccountViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var userDefaultsMonitor = UserDefaultsMonitor()
    
    private var totalDue: Int {
        let accountBalance = viewModel2.accounts.first?.availableBalance ?? 0
        return Int(accountBalance >= 0 ? 0 : abs(accountBalance))
    }
    
    // Computed property to filter and group invoices by month
    private var filteredInvoices: [MonthGroup] {
        let baseInvoices: [Invoice]
        switch isPaid {
        case "true":
            baseInvoices = viewModel.invoices.filter { $0.isPaid == true }
        case "false":
            baseInvoices = viewModel.invoices.filter { $0.isPaid == false }
        default:
            baseInvoices = viewModel.invoices
        }
        
        // Helper function to convert month string to Date for proper sorting
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        
        func getDate(from monthString: String) -> Date {
            return dateFormatter.date(from: monthString) ?? Date.distantPast
        }
        
        // Group invoices by invoiceMonth
        let grouped = Dictionary(grouping: baseInvoices) { invoice in
            invoice.invoiceMonth
        }
        
        // Convert to array and sort by actual month dates descending
        return grouped.map { month, invoices in
            MonthGroup(
                month: month,
                invoices: invoices.sorted { $0.invoiceNumber > $1.invoiceNumber }
            )
        }.sorted {
            getDate(from: $0.month) > getDate(from: $1.month)
        }
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Header Section
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
                            
                            Text("Invoice")
                                .font(.custom("Montserrat-Bold", size: 22))
                                .foregroundColor(.specialText)
                            
                            Spacer()
                            
                            Button(action: {
                                showingSettings = true
                            }) {
                                InitialProfileImage(
                                    username: userDefaultsMonitor.mainName,
                                    size: 30,
                                    backgroundColor: .specialText,
                                    textColor: .onMainTheme
                                )
                            }
                            .foregroundStyle(.specialText)
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        
                    }
                    
                    VStack(spacing: 0) {
                        
                        // If you have a custom top bar, you can place it here
                        // TopBarView()
                        
                        // Due Amount Section
                        if totalDue > 0 {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Total Due")
                                        .font(.custom("Montserrat-Regular", size: 15))
                                        .foregroundColor(.primary)
                                    
                                    Text("₹\(totalDue)")
                                        .font(.custom("Montserrat-Bold", size: 16))
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    matomoTracker.track(
                                        eventWithCategory: "clear dues",
                                        action: "tapped",
                                        url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
                                    )
                                    matomoTracker.track(view: ["Payment Initial Page"])
                                    paymentState.showingPayScreen = true
                                }) {
                                    Text("Clear Dues")
                                        .font(.custom("Montserrat-Medium", size: 16))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 7.5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
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
                                }
                                .disabled(!networkMonitor.isConnected)
                            }
                            .padding()
                            .background(.cards)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding()
                        }
                        
                        // Filter Buttons
                        HStack(spacing: 12) {
                            FilterButton(title: "All", isSelected: isPaid == "", action: {
                                matomoTracker.track(
                                    eventWithCategory: "invoice filter",
                                    action: "All tapped",
                                    url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
                                )
                                isPaid = ""
                                withAnimation {
                                    isDuePage = false
                                }
                            })
                            
                            FilterButton(title: "Due", isSelected: isPaid == "false", action: {
                                matomoTracker.track(
                                    eventWithCategory: "invoice filter",
                                    action: "Due tapped",
                                    url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
                                )
                                isPaid = "false"
                                withAnimation {
                                    isDuePage = true
                                }
                            })
                            
                            FilterButton(title: "Paid", isSelected: isPaid == "true", action: {
                                matomoTracker.track(
                                    eventWithCategory: "invoice filter",
                                    action: "Paid tapped",
                                    url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
                                )
                                isPaid = "true"
                                withAnimation {
                                    isDuePage = false
                                }
                            })
                            
                            Spacer()
                            
                            // Year Selector
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
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Invoice List
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 16) {
                                if filteredInvoices.count > 0 {
                                    ForEach(filteredInvoices) { monthGroup in
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(monthGroup.month)
                                                .font(.custom("Montserrat-SemiBold", size: 18))
                                                .foregroundColor(.primary)
                                                .padding(.horizontal, 16)
                                                .padding(.bottom, -8)
                                            
                                            ForEach(monthGroup.invoices, id: \.id) { invoice in
                                                InvoiceCardView(invoice: invoice)
                                                    .padding(.bottom, 8)
                                            }
                                        }
                                        .padding(.bottom, -8)
                                    }
                                } else {
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
                                            EmptyInvoiceView(isConnected: networkMonitor.isConnected)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
                .frame(width: geometry.size.width)
            }
        }
        .navigationDestination(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView(showSettings: $showingSettings)
            }
        }
        .fullScreenCover(isPresented: $paymentState.showingPayScreen) {
            NavigationStack {
                PaymentsView(
                    amount: totalDue,
                    showPayScreen: $paymentState.showingPayScreen,
                    year: Int(year) ?? 2025,
                    accountId: viewModel2.accounts.first?.id ?? "",
                    from: "invoice"
                )
                .navigationBarItems(leading: Button {
                    paymentState.showingPayScreen = false
                } label: {
                    Text("Back").tint(.primary)
                })
                .navigationBarTitle("Payment", displayMode: .inline)
            }
        }
        .tint(.white)
        .onAppear {
            matomoTracker.track(view: ["Invoice Page"])
            showProgress = true
            fetchInvoices()
            Task {
                await viewModel2.fetchAccounts(jsonQuery: [:])
            }
        }
        .onChange(of: paymentState.showingPayScreen) { _ in
            if !paymentState.showingPayScreen {
                showProgress = true
                fetchInvoices()
                Task {
                    await viewModel2.fetchAccounts(jsonQuery: [:])
                }
            }
        }
        .onChange(of: year) { _ in
            Task {
                await viewModel2.fetchAccounts(jsonQuery: [:])
            }
            fetchInvoices()
        }
        .onChange(of: networkMonitor.isConnected) { _ in
            if networkMonitor.isConnected {
                fetchInvoices()
            }
        }
        .onChange(of: userDefaultsMonitor.selectedUnitId) { _ in
            Task {
                await viewModel2.fetchAccounts(jsonQuery: [:])
            }
            fetchInvoices()
        }
    }
    
    private func fetchInvoices() {
        Task {
            // Matomo event: fetchInvoices triggered
            matomoTracker.track(
                eventWithCategory: "InvoiceView",
                action: "fetchInvoices called",
                url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
            )
            
            await viewModel.fetchInvoices(jsonQuery: [
                "filter[where][unitId]": userDefaultsMonitor.selectedUnitId,
                "filter[where][invoiceStatus]": "Sent",
                "filter[where][invoiceYear]": Int(year) ?? 2024,
                "filter[include][0][relation]": "invoiceItems",
            ])
        }
    }

    private struct EmptyInvoiceView: View {
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
                ? "No invoices found."
                : "Unable to fetch invoices.\nPlease check your internet connection."
        }
    }
}

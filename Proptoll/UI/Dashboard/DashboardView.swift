import SwiftUI
import Sentry
import Charts

struct DashboardView: View {
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @StateObject private var viewModel = AccountViewModel()
    @StateObject private var userDefaultsMonitor = UserDefaultsMonitor()
    @StateObject var viewModel2 = TransactionViewModel()
    @State private var showSheet = false
    @State private var showingSettings = false
    @State private var showProgress = true
    @State private var showExpenseDetailView = false
    @State private var from = "account"
    @State private var empty = true
    @State private var barSelection: String?
    @State private var barSelection2 = ""
    @StateObject private var paymentState = PaymentStateModel()
    @State private var year = String(Calendar.current.component(.year, from: Date()))
    @State private var showingTransactions = false
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentPage = 0
    private let categoryColors: [Color] = [.bluePurple, .teal, .red, .gray]
    @State private var hasInitiallyLoaded = false
    
    private var accountBalance: Int {
        let balance = viewModel.accounts.first?.availableBalance ?? 0
        return balance < 0 ? 0 : Int(balance)
    }
    
    private var totalDue: Int {
        let balance = viewModel.accounts.first?.availableBalance ?? 0
        return balance > 0 ? 0 : Int(abs(balance))
    }
    
    private func monthToDate(_ month: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.date(from: month) ?? Date()
    }
    
    private var latestNonZeroMonth: String {
        dashboardViewModel.graph?.monthlyExpenses
            .filter { $0.billedAmount > 0 }
            .max(by: { monthToDate($0.month) < monthToDate($1.month) })?
            .month ?? ""
    }
    
    private var adjustedMaxAmount: Double {
        let maxAmount = (dashboardViewModel.graph?.monthlyExpenses ?? [])
            .map { $0.billedAmount }
            .max() ?? 0
        return maxAmount * 1.35
    }
    
    private var currentMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: Date())
    }
    
    private var currentYear: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: Date())
    }
    
    private var totalExpenses: Double {
        dashboardViewModel.graph?.yearlyExpenses.presentYearExpenses ?? 0
    }
    
    private var totalExpensesPrev: Double {
        dashboardViewModel.graph?.yearlyExpenses.previousYearExpenses ?? 0
    }
    
    private var processedExpenseData: [ServiceExpense] {
        let services = dashboardViewModel.graph?.yearlyExpenses.services.sorted { $0.presentYearAmount > $1.presentYearAmount } ?? []
        
        if services.count <= 3 {
            return services
        }
        
        var result = Array(services.prefix(3))
        let otherPresent = services.dropFirst(3).reduce(0.0) { $0 + $1.presentYearAmount }
        let otherPrevious = services.dropFirst(3).reduce(0.0) { $0 + $1.previousYearAmount }
        
        result.append(
            ServiceExpense(
                serviceName: "Other",
                presentYearAmount: otherPresent,
                previousYearAmount: otherPrevious
            )
        )
        
        return result
    }
    
    private var nextYear: String {
        if let currentYear = Int(year) {
            return String(currentYear + 1)
        }
        return String(Calendar.current.component(.year, from: Date()) + 1)
    }
    
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
        .onChange(of: barSelection) { _ in
            if barSelection ?? "" != "" {
                barSelection2 = barSelection ?? ""
            }
        }
        .tint(.white)
        .navigationDestination(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView(showSettings: $showingSettings)
            }
        }
        .fullScreenCover(isPresented: $showExpenseDetailView) {
            NavigationStack {
                ExpenseDetailView(
                    expenseData: dashboardViewModel.graph?.yearlyExpenses.services ?? [],
                    totalExpenses: totalExpenses,
                    totalExpensesPrev: totalExpensesPrev
                )
                .navigationBarItems(leading: Button {
                    showExpenseDetailView = false
                } label: {
                    Text("Back").tint(.primary)
                })
                .navigationBarTitle("Expenses", displayMode: .inline)
            }
        }
        .fullScreenCover(isPresented: $paymentState.showingPayScreen) {
            NavigationStack {
                PaymentsView(
                    amount: Int(abs(dashboardViewModel.graph?.yearlyExpenses.presentYearExpenses ?? 0)),
                    showPayScreen: $paymentState.showingPayScreen,
                    year: Int(year) ?? Calendar.current.component(.year, from: Date()),
                    accountId: userDefaultsMonitor.selectedAccountId,
                    from: from
                )
                .navigationBarItems(leading: Button {
                    paymentState.showingPayScreen = false
                } label: {
                    Text("Back").tint(.primary)
                })
                .navigationBarTitle("Payment", displayMode: .inline)
            }
        }
        .onAppear {
            if !hasInitiallyLoaded {
                handleOnAppear()
                hasInitiallyLoaded = true
            }
            else if userDefaultsMonitor.paymentRefresh {
                handleOnAppear()
                userDefaultsMonitor.updatePaymentRefreshStatus(false)
            }
        }
        .onChange(of: paymentState.showingPayScreen) { _ in
            if userDefaultsMonitor.paymentRefresh {
                handleOnAppear()
                userDefaultsMonitor.updatePaymentRefreshStatus(false)
            }
        }
        .onChange(of: userDefaultsMonitor.selectedUnitId) { _ in
            handleOnAppear()
        }
        .onChange(of: networkMonitor.isConnected) { _ in
            if networkMonitor.isConnected {
                handleOnAppear()
            }
        }
        .onChange(of: year) { _ in
            handleOnAppear()
        }
    }
    
    private struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }
    
    private var monthlyExpensesChart: some View {
        let maxAmount = dashboardViewModel.graph?.monthlyExpenses.map { $0.billedAmount }.max() ?? 0
        let adjustedMaxAmount = maxAmount == 0 ? 1 : maxAmount * 1.35
        
        return VStack(alignment: .leading, spacing: 5) {
            if let monthlyExpenses = dashboardViewModel.graph?.monthlyExpenses, !monthlyExpenses.isEmpty {
                
                HStack {
                    Spacer()
                    VStack(spacing: 2.5) {
                        Text("Monthly Expenses")
                            .font(.custom("Montserrat-Medium", size: 16))
                        Text("(Tap to see amount)")
                            .font(.custom("Montserrat-Regular", size: 12))
                    }
                    .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.top)
                
                TabView(selection: $currentPage) {
                    let chunks = monthlyExpenses.chunked(into: 6)
                    ForEach(0..<chunks.count, id: \.self) { index in
                        Chart(chunks[index], id: \.month) { expense in
                            let displayAmount = expense.billedAmount
                            
                            BarMark(
                                x: .value("Month", expense.month),
                                y: .value("Amount", displayAmount),
                                width: .fixed(25)
                            )
                            .foregroundStyle(
                                expense.month == latestNonZeroMonth && year == currentYear
                                ? .white
                                : .white.opacity(0.65)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 7.5))
                            .annotation(position: .overlay) {
                                if barSelection2 == expense.month {
                                    RoundedRectangle(cornerRadius: 7.5)
                                        .stroke(.white, lineWidth: 3)
                                        .padding(-4)
                                }
                            }
                            .annotation(position: .top) {
                                if expense.billedAmount > 0 {
                                    if barSelection2 == expense.month && barSelection2 != "" {
                                        VStack(spacing: 0) {
                                            Text("₹\(Int(expense.billedAmount).toKString())")
                                                .font(.custom("Montserrat-Bold", size: 12))
                                                .foregroundColor(.white)
                                                .padding(6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .fill(.cards.opacity(0.5))
                                                )
                                            
                                            Triangle()
                                                .fill(.cards.opacity(0.5))
                                                .frame(width: 10, height: 5)
                                                .rotationEffect(.degrees(180))
                                        }
                                        .offset(y: -10)
                                    }
                                }
                            }
                        }
                        .chartYScale(domain: 0...adjustedMaxAmount)
                        // Remove .chartXSelection and replace with an overlay gesture:
                        .chartOverlay { proxy in
                            GeometryReader { geo in
                                Rectangle()
                                    .fill(Color.clear)
                                    .contentShape(Rectangle())
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                // Convert the gesture's location to the chart's domain (month)
                                                if let monthName: String = proxy.value(atX: value.location.x) {
                                                    barSelection = monthName
                                                }
                                            }
                                           /* .onEnded { _ in
                                                // If you want to reset selection on gesture end, do it here:
                                                // barSelection = ""
                                            } */
                                    )
                            }
                        }
                        .chartYAxis(.hidden)
                        .chartXAxis {
                            AxisMarks { value in
                                AxisValueLabel {
                                    if let month = value.as(String.self) {
                                        Text(month.prefix(3))
                                            .font(.custom("Montserrat-Medium", size: 12))
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                        }
                        .frame(height: 160)
                        .onAppear {
                            barSelection2 = latestNonZeroMonth
                            // Matomo event for each tab chunk appear
                            matomoTracker.track(
                                eventWithCategory: "chart",
                                action: "monthly expenses chart displayed",
                                url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .onAppear {
                    if monthlyExpenses.count > 6 {
                        currentPage = 1
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .frame(height: 260)
            } else {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "tray.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.white)
                        
                        Text("No expenses recorded this year")
                            .font(.custom("Montserrat-Medium", size: 16))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
                .frame(height: 260)
            }
        }
        .padding(.vertical)
        .padding(.bottom)
        .padding(.top, 500)
        .background(Color.bluePurple)
        .offset(y: -500)
    }
    
    private var expenseOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .center) {
                        Text("Yearly Expenses")
                            .font(.custom("Montserrat-Medium", size: 14))
                        Spacer()
                    }
                    HStack(spacing: 4) {
                        Text("₹\(Int(totalExpenses))")
                            .font(.custom("Montserrat-Bold", size: 24))
                        if totalExpenses != totalExpensesPrev && totalExpensesPrev > 0 {
                            HStack(spacing: 2) {
                                if totalExpenses > totalExpensesPrev {
                                    Image(systemName: "arrow.up")
                                        .foregroundColor(.billDue)
                                } else {
                                    Image(systemName: "arrow.down")
                                        .foregroundColor(.billPaid)
                                }
                                Text(
                                    String(format: "%.2f", abs(
                                        ((totalExpensesPrev - totalExpenses) / totalExpensesPrev) * 100
                                    )) + "%"
                                )
                                .foregroundColor(
                                    totalExpenses > totalExpensesPrev ? .billDue : .billPaid
                                )
                            }
                            .font(.custom("Montserrat-Medium", size: 12))
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(Array(processedExpenseData.enumerated()), id: \.element.serviceName) { index, category in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(categoryColors[index])
                            .frame(
                                width: max(
                                    0,
                                    totalExpenses > 0
                                    ? (CGFloat(category.presentYearAmount) / CGFloat(totalExpenses) * geometry.size.width) - 4
                                    : 0
                                )
                            )
                            .padding(.horizontal, 2)
                    }
                }
            }
            .frame(height: 12)
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(Array(processedExpenseData.enumerated()), id: \.element.serviceName) { index, category in
                    HStack {
                        Circle()
                            .fill(categoryColors[index])
                            .frame(width: 8, height: 8)
                        Text(category.serviceName)
                            .font(.custom("Montserrat-Medium", size: 14))
                            .foregroundColor(.secondary)
                        
                        if category.presentYearAmount != category.previousYearAmount
                            && category.previousYearAmount > 0
                        {
                            HStack(spacing: 2) {
                                if category.presentYearAmount > category.previousYearAmount {
                                    Image(systemName: "arrow.up")
                                        .foregroundColor(.billDue)
                                } else {
                                    Image(systemName: "arrow.down")
                                        .foregroundColor(.billPaid)
                                }
                                Text(
                                    String(format: "%.2f", abs(
                                        (
                                            (category.presentYearAmount - category.previousYearAmount) /
                                            category.previousYearAmount
                                        ) * 100
                                    )) + "%"
                                )
                                .foregroundColor(
                                    category.presentYearAmount > category.previousYearAmount ? .billDue : .billPaid
                                )
                            }
                            .font(.custom("Montserrat-Medium", size: 12))
                        }
                        
                        Spacer()
                        Text("₹\(Int(category.presentYearAmount))")
                            .font(.custom("Montserrat-SemiBold", size: 14))
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.cards)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.top)
        .offset(y: -500)
        // Matomo event for tapping the expense overview
        .onTapGesture {
            matomoTracker.track(
                eventWithCategory: "expense detail",
                action: "view tapped",
                url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
            )
            showExpenseDetailView = true
        }
    }
    
    private var addMoneyButton: some View {
        Button(action: {
            matomoTracker.track(
                eventWithCategory: "account money",
                action: "tapped",
                url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
            )
            matomoTracker.track(view: ["Payment Initial Page"])
            Task {
                from = "account"
                paymentState.showingPayScreen = true
            }
        }) {
            HStack {
                Text("Recharge Account")
                    .font(.custom("Montserrat-SemiBold", size: 14))
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.bluePurple)
            )
        }
        .disabled(!networkMonitor.isConnected)
    }
    
    private var mainContent: some View {
        VStack(spacing: 10) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    monthlyExpensesChart
                    balanceCard
                    expenseOverview
                    TransactionsView(
                        showTrans: $showingTransactions,
                        transactions: viewModel2.transactions,
                        year: $year
                    )
                    .offset(y: -500)
                    .padding(.bottom, -500)
                }
            }
        }
    }
    
    private func handleOnAppear() {
        matomoTracker.track(view: ["Dashboard Page"])
        Task {
            await dashboardViewModel.fetchGraphData(
                year: Int(year) ?? Calendar.current.component(.year, from: Date()),
                accountId: userDefaultsMonitor.selectedAccountId
            )
            await viewModel2.fetchTransactions(
                jsonQuery: [
                    "filter[order]": "createdAt DESC",
                    "filter[where][and][0][createdAt][gte]": year,
                    "filter[where][and][1][createdAt][lt]": nextYear,
                ],
                id: userDefaultsMonitor.selectedAccountId
            )
            await viewModel.fetchAccounts(jsonQuery: [:])
        }
    }
    
    private var profileButton: some View {
        Button(action: { showingSettings = true }) {
            InitialProfileImage(
                username: UserDefaults.standard.string(forKey: "mainName") ?? "",
                size: 30,
                backgroundColor: .plotBar,
                textColor: .specialText
            )
        }
        .foregroundStyle(.specialText)
        .padding(.trailing)
    }
    
    private func headerView(geometry: GeometryProxy) -> some View {
        ZStack {
            Color(.bluePurple)
                .frame(height: geometry.safeAreaInsets.top)
                .ignoresSafeArea(.all)
            
            HStack(alignment: .top) {
                HStack(alignment: .center) {
                    Image(.proptollIconNoname)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 35)
                        .foregroundStyle(.orange)
                    
                    Text("Dashboard")
                        .font(.custom("Montserrat-Bold", size: 22))
                        .foregroundColor(.white)
                }
                
                Spacer()
                VStack(alignment: .trailing, spacing: 16) {
                    profileButton
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
                    .padding(.trailing)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.bottom, 5)
        }
        .background(.bluePurple)
        .foregroundStyle(.bluePurple)
    }
    
    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Upper section
            VStack(spacing: 16) {
                // Account Balance row
                HStack {
                    Image(.balanceIcon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                    Text("Account Balance")
                        .font(.custom("Montserrat-Medium", size: 14))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("₹\(accountBalance)")
                        .font(.custom("Montserrat-SemiBold", size: 16))
                        .foregroundStyle(.primary)
                }
                
                // Total Due row
                HStack {
                    Image(.dueIcon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                    Text("Total Due")
                        .font(.custom("Montserrat-Medium", size: 14))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("₹\(totalDue)")
                        .font(.custom("Montserrat-SemiBold", size: 16))
                        .foregroundStyle(
                            viewModel.accounts.first?.availableBalance ?? 0 < 0
                            ? .red
                            : .primary
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(.cards)
            
            // Bottom section
            HStack {
                addMoneyButton
                
                Spacer()
                
                PaymentRulesView(text: "Need Help?", color: .primary)
                    .onTapGesture {
                        // Matomo event for tapping "Need Help?"
                        matomoTracker.track(
                            eventWithCategory: "help",
                            action: "tapped PaymentRulesView",
                            url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
                        )
                    }
                    .scaleEffect(0.8)
                    .padding(.horizontal, -14)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color.cards)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.bottom, -40)
        .offset(y: -40)
        .offset(y: -500)
    }
}

import SwiftUI
import Combine
import SimpleKeychain

struct NoticeBoardView: View {
    // MARK: - Properties
    @StateObject private var viewModel = NoticeViewModel()
    @StateObject private var viewModel2 = OwnerViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var router = Router()
    @Environment(\.scenePhase) private var scenePhase
    @State private var cardCategoryId: [Int] = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var isSearching = false
    @State private var showingSettings = false
    @State private var offset = 0
    @State private var json: [String: Any] = [:]
    @State private var scrollViewProxy: ScrollViewProxy?
    @State private var searchTextDebounced = ""
    @State private var scrollTop = true
    @State private var limit = 20
    @State private var hideScrollView = false
    
    
    private let searchTextDebouncer = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    headerView(geometry: geometry)
                    
                    if !isSearching {
                        categoryView()
                    }
                    
                    noticeListView(geometry: geometry)
                }
                .frame(width: geometry.size.width)
            }
        }
        .onChange(of: networkMonitor.isConnected) { _ in
            if networkMonitor.isConnected {
                handleOnAppear()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("didTapRemoteNotification"))) { _ in
            refreshNotices()
            refresh = false
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if refresh == true {
                    refreshNotices()
                    refresh = false
                }
            }
        }
        .onChange(of: isSearching, perform: handleSearchChange)
        .onChange(of: searchText, perform: handleSearchTextChange)
        .tint(.blue)
        .navigationDestination(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView(showSettings: $showingSettings)
                
            }
        }
        .onChange(of: searchText, perform: { newValue in
            searchTextDebouncer.send(newValue)
        })
        .onReceive(
            searchTextDebouncer
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
        ) { debouncedSearchText in
            searchTextDebounced = debouncedSearchText
            Task{
                await viewModel.filteredNotices(searchText: debouncedSearchText)
            }
        }
        .onAppear(perform: handleOnAppear)
    }
    
    // MARK: - Subviews
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
                
                if isSearching {
                    SearchBar(text: $searchText, isSearching: $isSearching)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    Text("Noticeboard")
                        .foregroundStyle(.specialText)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                        .font(.custom("Montserrat-Bold", size: 22))
                }
                
                Spacer()
                
                if !isSearching {
                    searchButton
                }
                
                profileButton
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.bottom, 5)
        }
        .animation(.easeInOut(duration: 0.3), value: isSearching)
    }
    
    private var searchButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isSearching = true
                matomoTracker.track(eventWithCategory: "search button", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
            }
        }) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(height: 20)
                .foregroundColor(.primary)
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
    
    private var profileButton: some View {
        Button(action: {
            showingSettings = true
        }) {
            InitialProfileImage(username: UserDefaults.standard.string(forKey: "mainName") ?? "", size: 30, backgroundColor: .specialText, textColor: .onMainTheme)
        }
        .foregroundStyle(.specialText)
        .padding(.horizontal)
    }
    
    private func categoryView() -> some View {
        VStack(spacing: 0) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    categoryButton(title: "All")
                    categoryButton(title: "General", id: 1)
                    categoryButton(title: "Information", id: 2)
                    categoryButton(title: "Alert", id: 3)
                    categoryButton(title: "Emergency", id: 4)
                    categoryButton(title: "Event", id: 5)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .padding(.top, 10)
            }
        }
        .transition(.opacity)
    }
    
    private func noticeListView(geometry: GeometryProxy) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                if viewModel.notices.isEmpty {
                    emptyNoticeView(geometry: geometry)
                } else {
                    noticeList
                        .padding(.bottom, 24)
                }
            }
        }
        .refreshable {
            refreshNotices()
        }
        
    }
    
    private func emptyNoticeView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Conditional Image or ProgressView based on isLoading
            if isLoading {
                // Loading State
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(1.5)
                    .accessibilityLabel("Loading Notices")
            } else {
                // Empty or Error State
                Image(systemName: viewModel.error == "empty" ? "doc.text.magnifyingglass" : "wifi.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .foregroundColor(viewModel.error == "empty" ? .gray : .red)
                    .accessibilityLabel(viewModel.error == "empty" ? "No notices available" : "No internet connection")
            }
            
            // Descriptive Text
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 40)
        .onAppear {
            // Maintain existing onAppear logic
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if viewModel.notices.isEmpty {
                    isLoading = false
                }
            }
        }
    }
    
    // Computed property for dynamic messages
    private var message: String {
        if isLoading {
            return "Fetching Notices..."
        } else {
            return viewModel.error == "empty" ? "No notices found!" : "Check your internet connection!"
        }
    }
    
    private var noticeList: some View {
        ScrollViewReader { proxy in
            if !hideScrollView {
                VStack(spacing: 24) {
                    ForEach(viewModel.notices, id: \.id) { notice in
                        if cardCategoryId.isEmpty || cardCategoryId.contains(notice.noticeCategoryId) {
                            noticeLink(for: notice)
                        }
                    }
                    loadMoreButton
                }
                .padding(.top, 5)
                .onAppear {
                    scrollViewProxy = proxy
                }
                .onChange(of: viewModel.notices) { _ in
                    handleNoticesChange(proxy: proxy)
                }
            }
        }
    }
    
    private func noticeLink(for notice: Notice) -> some View {
        NavigationStack
        {
            NoticeBoardcardView(notice: notice)
                .shadow(radius: 0.25)
                .padding(.horizontal)
                .id(notice == viewModel.notices.first ? "top" : notice.id)
        }
        
    }
    
    @ViewBuilder
    private var loadMoreButton: some View {
        if viewModel.notices.count >= 20 && viewModel.notices.count % 20 == 0 && !isSearching {
            Button(action: loadMoreNotices) {
                Text("Load More")
                    .font(.custom("Montserrat-Medium", size: 16))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
    
    // MARK: - Helper Methods
    private func categoryButton(title: String, id: Int? = nil) -> some View {
        let isSelected = Binding<Bool>(
            get: { id == nil ? cardCategoryId.isEmpty : cardCategoryId == [id!] },
            set: { _ in }
        )
        
        return RoundedRectangle(cornerRadius: 20)
            .fill(isSelected.wrappedValue ? Color.plotBar : .onMainTheme)
            .frame(width: CGFloat(title.count * 10 + 10), height: 30)
            .overlay(
                HStack{
                    Text(title)
                        .font(.custom("Montserrat-Regular", size: 13))
                        .foregroundStyle(isSelected.wrappedValue ? .specialText : .primary)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.customPrimary, lineWidth: 0.25)  // Same color as Divider
            )
            .onTapGesture {
                handleCategoryTap(id: id)
            }
    }
    
    
    private func handleCategoryTap(id: Int?) {
        if #available(iOS 17.0, *){
            hideScrollView = true
        }
        offset = 0
        limit = 20
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            hideScrollView = false
        }
        
        if let id = id {
            cardCategoryId = [id]
            fetchNotices(with: ["filter[where][noticeCategoryId]": id])
        } else {
            cardCategoryId = []
            fetchNotices()
        }
    }
    
    private func fetchNotices(with additionalFilters: [String: Any] = [:]) {
        var filters: [String: Any] = [
            "filter[order]": "updatedAt DESC",
            "filter[limit]": limit,
            "filter[offset]": offset,
            "filter[include][0][relation]": "noticeActivityLogs",
            "filter[where][noticeStatus]": 2
        ]
        filters.merge(additionalFilters) { (_, new) in new }
        Task {
            await viewModel.fetchNotices(jsonQuery: filters)
            json = filters
        }
    }
    
    private func loadMoreNotices() {
        scrollTop = false
        offset += 20
        var updatedJson = json
        updatedJson["filter[offset]"] = offset
        Task {
            await viewModel.fetchMoreNotices(jsonQuery: updatedJson)
        }
    }
    
    private func refreshNotices() {
        isLoading = true
        viewModel.notices.removeAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if viewModel.notices.isEmpty {
                isLoading = false
            }
        }
        if !isSearching{
            offset = 0
            var updatedJson = json
            updatedJson["filter[offset]"] = offset
            Task {
                await viewModel.fetchNotices(jsonQuery: json)
            }
        }
    }
    
    private func handleSearchChange(_ newValue: Bool) {
        if newValue == false {
            offset = 0
            limit = 20
            fetchNotices(with: cardCategoryId.isEmpty ? [:] : ["filter[where][noticeCategoryId]": cardCategoryId.first ?? 0])
        }
    }
    
    private func handleSearchTextChange(_ newValue: String) {
        searchText = newValue.lowercased()
    }
    
    private func handleNoticesChange(proxy: ScrollViewProxy) {
        if scrollTop {
            withAnimation {
                proxy.scrollTo("top", anchor: .top)
            }
        } else {
            scrollTop = true
        }
    }
    
    private func handleOnAppear() {
        //print("fcmTOken: \(try? keychain.string(forKey: "fcmToken"))")
        matomoTracker.track(view: ["NoticeBoard Page"])
        router.reset()
        fetchNotices()
        let jwt = try? keychain.string(forKey: "jwtToken")
        //print("JWT: \(jwt ?? "")")
    }
}

#Preview {
    NoticeBoardView()
}

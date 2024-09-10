import SwiftUI


struct NoticeBoardView: View {
    @StateObject var viewModel = NoticeViewModel()
    @StateObject var viewModel2 = OwnerViewModel()
    @State private var cardCategoryId: [Int] = []
    @StateObject private var router = Router()
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showingSettings = false
    @State private var offset = 0
    @State private var json: [String: Any] = [:]

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ZStack {
                        Color(UIColor.systemGray4)
                            .frame(height: geometry.safeAreaInsets.top)
                            .ignoresSafeArea(.all)
                        HStack {
                            Image(systemName: "house")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding()
                                .foregroundStyle(.primary)

                            if isSearching {
                                SearchBar(text: $searchText, isSearching: $isSearching)
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                                    .onDisappear()
                                {
                                    Task{
                                        await viewModel.fetchNotices(jsonQuery: [
                                            "filter[order]": "updatedAt DESC",
                                            "filter[limit]": 100,
                                            "filter[offset]": offset
                                        ])
                                        json = [
                                            "filter[order]": "updatedAt DESC",
                                            "filter[limit]": 100,
                                            "filter[offset]": offset
                                        ]
                                    }
                                }
                            } else {
                                Text("Noticeboard")
                                    .foregroundStyle(.primary)
                                    .transition(.move(edge: .leading).combined(with: .opacity))
                            }

                            Spacer()

                            if !isSearching {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        cardCategoryId = []
                                        isSearching = true
                                        matomoTracker.track(eventWithCategory: "search button", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                                    }
                                }) {
                                    Image(systemName: "magnifyingglass")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.primary)
                                }
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                               
                            }

                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.primary)
                            }
                            .padding(.horizontal)
                        }
                        .frame(width: 375, alignment: .leading)
                        .padding(.horizontal)
                    }
                    .background(Color(UIColor.systemGray4))
                    .animation(.easeInOut(duration: 0.3), value: isSearching)

                    if !isSearching {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                categoryButton(title: "All")
                                    .onTapGesture {
                                        matomoTracker.track(eventWithCategory: "All button", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                                    }
                                categoryButton(title: "General", id: 1)
                                    .onTapGesture {
                                        matomoTracker.track(eventWithCategory: "General button", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                                    }
                                categoryButton(title: "Information", id: 2)
                                    .onTapGesture {
                                        matomoTracker.track(eventWithCategory: "Information button", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                                    }
                                categoryButton(title: "Alert", id: 3)
                                    .onTapGesture {
                                        matomoTracker.track(eventWithCategory: "Alert button", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                                    }
                                categoryButton(title: "Emergency", id: 4)
                                    .onTapGesture {
                                        matomoTracker.track(eventWithCategory: "Emergency button", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                                    }
                                categoryButton(title: "Event", id: 5)
                                    .onTapGesture {
                                        matomoTracker.track(eventWithCategory: "Event button", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                                    }
                            }
                            .padding()
                        }
                        .transition(.opacity)
                    }
                    
                    if viewModel.notices.isEmpty {
                        VStack{
                            Spacer()
                            Text("Fetching Notices...")
                                .font(.system(size: 20))
                                .foregroundStyle(Color(UIColor.systemGray))
                            ProgressView()
                            Spacer()
                        }
                    }
                    else
                    {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 16) {
                                ForEach(viewModel.notices, id: \.id) { notice in
                                    if cardCategoryId.isEmpty || cardCategoryId.contains(notice.noticeCategoryId) {
                                        NoticeBoardcardView(notice: notice)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                        .refreshable {
                            Task
                            {
                                await viewModel.fetchNotices(jsonQuery:json)
                            }
                        }
                    }

                    Spacer()
                }
            }
        }
        .fullScreenCover(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
                    .navigationBarItems(leading: Button("Back") {
                        showingSettings = false
                    })
                    .navigationBarTitle("Settings", displayMode: .inline)
            }
        }
        .onChange(of: searchText, { oldValue, newValue in
            Task{
                await viewModel.filteredNotices(searchText: searchText)
            }
        })
        .onAppear {
            matomoTracker.track(view: ["NoticeBoard Page"])
            router.reset()
            Task{
                await viewModel.fetchNotices(jsonQuery: [
                    "filter[order]": "updatedAt DESC",
                    "filter[limit]": 100,
                    "filter[offset]": offset
                ])
                json = [
                    "filter[order]": "updatedAt DESC",
                    "filter[limit]": 100,
                    "filter[offset]": offset
                ]
            }
        }
    }

    private func categoryButton(title: String, id: Int? = nil) -> some View {
        let isSelected = Binding<Bool>(
            get: { id == nil ? cardCategoryId.isEmpty : cardCategoryId == [id!] },
            set: { _ in }
        )

        return RoundedRectangle(cornerRadius: 10)
            .fill(isSelected.wrappedValue ? Color.purple : Color(UIColor.systemGray4))
            .frame(width: CGFloat(title.count * 10 + 20), height: 30)
            .overlay(
                Text(title)
                    .foregroundColor(.primary)
            )
            .onTapGesture {
                if let id = id {
                    cardCategoryId = [id]
                    Task {
                        await viewModel.fetchNotices(jsonQuery: [
                            "filter[order]": "updatedAt DESC",
                            "filter[limit]": 100,
                            "filter[offset]": offset,
                            "filter[where][noticeCategoryId]": id,
                        ])
                        json = [
                            "filter[order]": "updatedAt DESC",
                            "filter[limit]": 100,
                            "filter[offset]": offset,
                            "filter[where][noticeCategoryId]": id,
                        ]
                    }
                } else {
                    cardCategoryId = []
                    Task {
                        await viewModel.fetchNotices(jsonQuery: [
                            "filter[order]": "updatedAt DESC",
                            "filter[limit]": 100,
                            "filter[offset]": offset
                        ])
                        json = [
                            "filter[order]": "updatedAt DESC",
                            "filter[limit]": 100,
                            "filter[offset]": offset
                        ]
                    }
                }
            }
    }
}

#Preview {
    NoticeBoardView()
}

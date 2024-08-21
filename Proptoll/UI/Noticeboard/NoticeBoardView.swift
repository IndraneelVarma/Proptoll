import SwiftUI

struct NoticeBoardView: View {
    @StateObject var viewModel = NoticeViewModel()
    @State private var cardCategoryId: [Int] = []
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showingSettings = false
    @State private var offset = 0
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ZStack {
                        Color.gray
                            .frame(height: geometry.safeAreaInsets.top)
                            .ignoresSafeArea(.all)
                        HStack {
                            Image(systemName: "house")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding()
                                .foregroundStyle(.white)
                            
                            if isSearching {
                                SearchBar(text: $searchText, isSearching: $isSearching)
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                                    .onDisappear()
                                {
                                    Task{
                                        offset = 0
                                        await viewModel.fetchNotices(jsonQuery: [
                                            "filter[order]": "updatedAt DESC",
                                            "filter[limit]": 100,
                                            "filter[offset]": offset
                                        ])
                                    }
                                }
                            } else {
                                Text("Noticeboard")
                                    .foregroundStyle(.white)
                                    .transition(.move(edge: .leading).combined(with: .opacity))
                            }
                            
                            Spacer()
                            
                            if !isSearching {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isSearching = true
                                    }
                                }) {
                                    Image(systemName: "magnifyingglass")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.white)
                                }
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                            
                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 375, alignment: .leading)
                        .padding(.horizontal)
                    }
                    .background(Color.gray)
                    .animation(.easeInOut(duration: 0.3), value: isSearching)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            categoryButton(title: "All")
                            categoryButton(title: "General", id: 1)
                            categoryButton(title: "Information", id: 2)
                            categoryButton(title: "Alert", id: 3)
                            categoryButton(title: "Emergency", id: 4)
                            categoryButton(title: "Event", id: 5)
                        }
                        .padding()
                    }
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            if viewModel.notices.isEmpty {
                                Text("No results found")
                            } else {
                                ForEach(viewModel.notices, id: \.self) { notice in
                                    if cardCategoryId.isEmpty || cardCategoryId.contains(notice.noticeCategoryId) {
                                        NoticeBoardcardView(notice: notice)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
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
        .onChange(of: offset, { oldValue, newValue in
            offset += 10
        })
        .onChange(of: searchText, { oldValue, newValue in
            Task{
                await viewModel.filteredNotices(searchText: searchText)
            }
        })
        .onAppear {
            Task{
                await viewModel.fetchNotices(jsonQuery: [
                    "filter[order]": "updatedAt DESC",
                    "filter[limit]": 100,
                    "filter[offset]": offset
                ])
            }
        }
    }
    
    private func categoryButton(title: String, id: Int? = nil) -> some View {
        let isSelected = Binding<Bool>(
            get: { id == nil ? cardCategoryId.isEmpty : cardCategoryId == [id!] },
            set: { _ in }
        )
        
        return RoundedRectangle(cornerRadius: 10)
            .fill(isSelected.wrappedValue ? Color.purple : Color.gray)
            .frame(width: CGFloat(title.count * 10 + 20), height: 30)
            .overlay(
                Text(title)
                    .foregroundColor(.white)
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
                    }
                } else {
                    cardCategoryId = []
                    Task {
                        await viewModel.fetchNotices(jsonQuery: [
                            "filter[order]": "updatedAt DESC",
                            "filter[limit]": 100,
                            "filter[offset]": offset
                        ])
                    }
                }
            }
    }
}

#Preview {
    NoticeBoardView()
}

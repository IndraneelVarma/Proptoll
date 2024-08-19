import SwiftUI

struct NoticeBoardView: View {
    @StateObject var viewModel = NoticeViewModel()
    @State private var cardCategoryId: [Int] = [1,2,3,4,5]
    @State private var searchText = ""
    @State private var isSearching = false
    
    var filteredNotices: [Notice] {
        if searchText.isEmpty {
            return viewModel.notices
        } else {
            return viewModel.notices.filter { notice in
                notice.title.lowercased().contains(searchText.lowercased()) ||
                notice.subTitle.lowercased().contains(searchText.lowercased()) ||
                String(notice.postNumber).contains(searchText)
            }
        }
    }
    
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
                            
                            NavigationLink(destination: SettingsView()) {
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
                    
                    if !isSearching {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                categoryButton(title: "All", ids: [1, 2, 3, 4, 5])
                                categoryButton(title: "General", id: 1)
                                categoryButton(title: "Information", id: 2)
                                categoryButton(title: "Alert", id: 3)
                                categoryButton(title: "Emergency", id: 4)
                                categoryButton(title: "Event", id: 5)
                            }
                            .padding()
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            if filteredNotices.isEmpty {
                                Text("No results found")
                            } else {
                                ForEach(filteredNotices, id: \.self) { notice in
                                    if cardCategoryId.contains(notice.noticeCategoryId) {
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
        .onAppear {
            viewModel.fetchNotices(authToken: jwtToken, limit: 20, orderItem: "updatedAt", order: "DESC")
        }
    }
    
    private func categoryButton(title: String, id: Int? = nil, ids: [Int]? = nil) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(isSelected(id: id, ids: ids) ? Color.purple : Color.gray)
            .frame(width: CGFloat(title.count * 10 + 20), height: 30)
            .overlay(
                Text(title)
                    .foregroundColor(.white)
            )
            .onTapGesture {
                if let ids = ids {
                    cardCategoryId = ids
                } else if let id = id {
                    cardCategoryId = [id]
                }
            }
    }
    
    private func isSelected(id: Int?, ids: [Int]?) -> Bool {
        if let ids = ids {
            return cardCategoryId == ids
        } else if let id = id {
            return cardCategoryId == [id]
        }
        return false
    }
}



#Preview {
    NoticeBoardView()
}

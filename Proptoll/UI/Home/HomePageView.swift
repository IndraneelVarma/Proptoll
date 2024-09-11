import SwiftUI
import MatomoTracker

struct HomePageView: View {
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab: Int
    
    init(tabItem: Int = 1) {
        _selectedTab = State(initialValue: tabItem)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NoticeBoardView()
                .tabItem {
                    Image(systemName: "bookmark.square.fill")
                    Text("Notice Board")
                }
                .tag(1)
            
            BillsView()
                .tabItem {
                    Image(systemName: "dollarsign")
                    Text("Bills")
                }
                .tag(2)
            
            ReceiptsView()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Receipts")
                }
                .tag(3)
        }
        .onAppear(){
            jwtToken = UserDefaults.standard.string(forKey: "jwtToken") ?? ""
        }
        .preferredColorScheme(userTheme.colorScheme)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    HomePageView()
}

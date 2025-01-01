import SwiftUI
import MatomoTracker
import SimpleKeychain

struct HomePageView: View {
    @State var selectedTab: Int
    @StateObject private var viewModel4 = NotificationViewModel()
    @StateObject private var monitor = UserDefaultsMonitor()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showOnboarding = false
    
    
    init(tabItem: Int = 1) {
        _selectedTab = State(initialValue: tabItem)
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor.cards // or your desired color
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().standardAppearance = appearance
        UIPageControl.appearance().currentPageIndicatorTintColor = .bluePurple  // Selected dot color
        UIPageControl.appearance().pageIndicatorTintColor = .gray.withAlphaComponent(0.5)  // Unselected dots color
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                
                DashboardView()
                    .tabItem {
                        Image(.dashIcon)
                            .renderingMode(.template)
                        Text("Dashboard")
                            .font(.custom("Montserrat-Regular", size: 13))
                    }
                    .tag(1)
                    .background(.mainTheme)
                
                NoticeBoardView()
                    .tabItem {
                        Image(systemName: "bookmark.square.fill")
                        Text("Notice Board")
                            .font(.custom("Montserrat-Regular", size: 13))
                    }
                    .tag(2)
                    .background(.mainTheme)
                
                InvoiceView()
                    .tabItem {
                        if #available(iOS 18, *) {
                            Image(systemName: "text.document")
                        }
                        else {
                            Image(systemName: "dollarsign")
                        }
                        Text("Invoices")
                            .font(.custom("Montserrat-Regular", size: 13))
                    }
                    .tag(3)
                    .background(.mainTheme)
                
                
                ReceiptsView()
                    .tabItem {
                        if #available(iOS 18, *) {
                            Image(systemName: "text.page")
                        }
                        else {
                            Image(systemName: "newspaper")
                        }
                        Text("Receipts")
                            .font(.custom("Montserrat-Regular", size: 13))
                    }
                    .tag(4)
                    .background(.mainTheme)
            }
            .tint(.specialText)
            .onAppear {
                //print("home on appear")
                //print("owners count: \(UserDefaults.standard.integer(forKey: "ownerCount"))")
                //print("userDefaults monitor: \(monitor.selectedUnitId), \(monitor.selectedAccountId)")
                // Check if onboarding should be shown
                if !UserDefaults.standard.bool(forKey: "hasSeenOnboarding") && UserDefaults.standard.bool(forKey: "isLoggedIn"){
                    showOnboarding = true
                }
                
                // Existing onAppear code
                matomoTracker.setDimension(UserDefaults.standard.string(forKey: "mainPhoneNumber") ?? "", forIndex: 1)
                matomoTracker.setDimension(UserDefaults.standard.string(forKey: "mainName") ?? "", forIndex: 2)
                matomoTracker.setDimension("\(Bundle.main.releaseVersionNumber)", forIndex: 3)
                matomoTracker.setDimension("Native IOS", forIndex: 4)
                matomoTracker.setDimension("\(UserDefaults.standard.string(forKey: "organization") ?? "")", forIndex: 5)
                
                // Print Realm database contents
                //print("\n=== REALM DATABASE CONTENTS ===")
                let realm = RealmManager.shared.realm
                
                // Print Owners
                let owners = realm.objects(OwnerRealm.self)
                //print("\nOWNERS (\(owners.count) total):")
                owners.forEach { owner in
                    //print("\nOwner:")
                    //print("  ID: \(owner.id)")
                    //print("  ----------------------")
                }
                
                // Print Realm file location
                //print("\nRealm Database Location:")
                //print(realm.configuration.fileURL?.path ?? "Unknown location")
                //print("\n=== END OF REALM CONTENTS ===\n")
                
                // Continue with existing setup
                setupApp()
                Task {
                    await viewModel4.registerNotifications(jsonQuery: [:])
                }
            }
            .onChange(of: scenePhase) { newPhase in
                //print("fromContentView: \(UserDefaults.standard.bool(forKey: "fromContentView"))")
                        if UserDefaults.standard.bool(forKey: "fromContentView"){
                            if newPhase == .active {
                                setupApp()
                            }
                            else if newPhase == .background || newPhase == .inactive{
                                UserDefaults.standard.set(false, forKey: "showHome")
                            }
                        }
                    }
                    .onChange(of: selectedTab) { _ in
                        UserDefaults.standard.set(selectedTab,forKey:"homePage")
                        //print("tabOnChange \(selectedTab)")
                    }
                    .onChange(of: UserDefaults.standard.integer(forKey:"homePage")){ _ in
                        selectedTab = UserDefaults.standard.integer(forKey:"homePage")
                        //print("tabOnChange2 \(selectedTab)")
                    }
            .navigationBarBackButtonHidden(true)
            
            // Onboarding overlay
            if showOnboarding {
                OnboardingOverlay(isVisible: $showOnboarding)
            }
        }
    }
    
    private func setupApp() {
        let jwtToken1 = try? keychain.string(forKey: "jwtToken")
        jwtToken = jwtToken1 ?? ""
        
        if UserDefaults.standard.bool(forKey: "showHome") {
            if !UserDefaults.standard.bool(forKey: "fromSettings") {
                UserDefaults.standard.set(1, forKey: "homePage")
            }
            else {
                UserDefaults.standard.set(false, forKey: "fromSettings")
            }
        }
        else {
            UserDefaults.standard.set(true, forKey: "showHome")
        }
        
        selectedTab = UserDefaults.standard.integer(forKey: "homePage")
    }
}

#Preview {
    HomePageView()
}

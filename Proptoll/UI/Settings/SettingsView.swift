import SwiftUI
import RealmSwift

struct SettingsView: View {
    // MARK: - Properties
    
    // Environment & StateObjects
    @Environment(\.colorScheme) private var scheme
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var router: Router
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var userDefaultsMonitor = UserDefaultsMonitor()
    // State & Binding
    @Binding var showSettings: Bool
    @State private var isNotificationOn = UserDefaults.standard.bool(forKey: "notis")
    @State private var showCookie = false
    @State private var showLogoutAlert = false
    @State private var navigateToLogin = false // Added for navigationDestination
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack {
                        TopBarView()
                        profileSection
                        generalSection
                        settingsSection
                        logoutSection
                       // feedbackSection
                        aboutSection
                    }
                }
                
                if showCookie {
                    cookieToast
                }
            }
            .tint(.blue)
            .onAppear(perform: handleOnAppear)
            .onChange(of: UserDefaults.standard.string(forKey: "route"), perform: handleRouteChange)
            .onChange(of: scenePhase, perform: handleScenePhaseChange)
            .background(.mainTheme)
            .navigationDestination(isPresented: $navigateToLogin) {
                ContentView()
            }
        }
    }
    
    // MARK: - View Components
    
    private var profileSection: some View {
        HStack {
            Spacer()
            VStack {
                InitialProfileImage(
                    username: UserDefaults.standard.string(forKey: "mainName") ?? "",
                    size: 70,
                    backgroundColor: .settingsButton,
                    textColor: .primary
                )
                .padding(.top)
                .padding(.bottom)
                
                Text(UserDefaults.standard.string(forKey: "mainName") ?? "")
                    .font(.custom("Montserrat-Medium", size: 22))
                    .foregroundStyle(.primary)
                    .padding(.bottom)
            }
            Spacer()
        }
        .offset(y: 1)
    }
    
    private var generalSection: some View {
        VStack {
            sectionHeader("General")
            
            NavigationLink(destination: ProfileView()) {
                ProfileCardView(image: "person.circle", mainText: "Profile", subText: "Account details")
            }
            .foregroundStyle(.primary)
            
            NavigationLink(destination: UserGuideView()) {
                ProfileCardView(image: "text.book.closed", mainText: "User Guide", subText: "View app features")
            }
            .foregroundStyle(.primary)
            
            NavigationLink(destination: WhatsNewView()) {
                WhatsNewCard(image: "checkmark.seal", mainText: "What's New", subText: "View the changes added in the current verison")
            }
            .foregroundStyle(.primary)
            
            NavigationLink(destination: FAQView()) {
                       ProfileCardView(image: "questionmark.circle", mainText: "FAQs", subText: "Frequently asked questions")
                   }
                   .foregroundStyle(.primary)
        }
    }
    
    private var settingsSection: some View {
        VStack {
            sectionHeader("Settings")
            
            themeToggle
            notificationToggle
            
            OrganizationView()
                .padding(20)
                
        }
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
    }
    
    private var themeToggle: some View {
        HStack {
            Image(systemName: "circle.lefthalf.filled")
                .resizable()
                .scaledToFit()
                .frame(height: 22.5)
                .foregroundStyle(.primary)
                .padding(.leading, 20)
                .padding(.trailing)
                .padding(.bottom, 10)
            
            Text("Dark Theme")
                .font(.custom("Montserrat-Regular", size: 16))
            
            Spacer()
            
            ThemeChangeView(scheme: scheme)
                .padding(.trailing, 20)
        }
        .padding(.vertical, 10)
    }
    
    private var notificationToggle: some View {
        VStack {
            Divider()
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            
            HStack {
                Image(systemName: "bell")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 22.5)
                    .foregroundStyle(.primary)
                    .padding(.trailing)
                
                Toggle("Notifications", isOn: $isNotificationOn)
                    .disabled(!networkMonitor.isConnected)
                    .font(.custom("Montserrat-Regular", size: 16))
                    .foregroundStyle(.primary)
                    .toggleStyle(CustomToggle(onImage: "checkmark", offImage: ""))
                    .onChange(of: isNotificationOn) { _ in
                        handleNotificationToggle()
                    }
            }
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            
            Divider()
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        }
        .padding(.vertical, 10)
    }
    
    private var logoutSection: some View {
        VStack {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.forward")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 22.5)
                    .foregroundStyle(.primary)
                Button(action: { showLogoutAlert = true }) {
                    Text("Logout")
                        .font(.custom("Montserrat-Regular", size: 16))
                        .underline()
                        .tint(.primary)
                }
                .padding(.leading)
                .disabled(!networkMonitor.isConnected)
                .alert("Logout", isPresented: $showLogoutAlert) {
                    Button("Cancel", role: .cancel) { }
                    
                    Button("Confirm") {
                        performLogout()
                        navigateToLogin = true // Trigger navigation
                    }
                    .disabled(!networkMonitor.isConnected)
                } message: {
                    Text("Are you sure you want to logout?")
                }
                
                Text(networkMonitor.isConnected ? "" : "No Internet Connection!")
                    .font(.custom("Montserrat-Medium", size: 16))
                    .foregroundStyle(.red)
                
                Spacer()
            }
            .padding(20)
            
            Divider()
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        }
        
    }
    
    private var feedbackSection: some View {
        VStack {
            HStack {
                Image(systemName: "bubble.left")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 22.5)
                    .foregroundStyle(.primary)
                NavigationLink {
                    FeedbackView()
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("Feedback")
                } label: {
                    Text("Feedback")
                        .font(.custom("Montserrat-Regular", size: 16))
                        .underline()
                        .tint(.primary)
                }
                .padding(.leading)
                
                Spacer()
            }
            .padding(20)
            
            Divider()
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        }
    }
    
    
    private var aboutSection: some View {
        VStack {
            HStack {
                Image(systemName: "info.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 22.5)
                    .foregroundStyle(.primary)
                NavigationLink {
                    AboutView()
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("About")
                } label: {
                    Text("About")
                        .font(.custom("Montserrat-Regular", size: 16))
                        .underline()
                        .tint(.primary)
                }
                .padding(.leading)
                
                Spacer()
            }
            .padding(20)
            
            Divider()
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        }
    }
    
    private var cookieToast: some View {
        VStack {
            Spacer()
            Text("Copied to clipboard!")
                .padding()
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
                .transition(.move(edge: .bottom))
        }
        .zIndex(1)
        .animation(.easeInOut, value: showCookie)
        .opacity(0.85)
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.custom("Montserrat-Medium", size: 18))
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Methods
    
    private func handleOnAppear() {
        matomoTracker.track(view: ["Settings Page"])
        UserDefaults.standard.set(true, forKey: "fromSettings")
    }
    
    private func handleRouteChange(_ newRoute: String?) {
        if (newRoute ?? "").isEmpty {
            showSettings = false
        }
    }
    
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        if newPhase == .inactive || newPhase == .background {
            UserDefaults.standard.set(false, forKey: "fromSettings")
        } else {
            UserDefaults.standard.set(true, forKey: "fromSettings")
        }
    }
    
    private func handleNotificationToggle() {
        UserDefaults.standard.set(isNotificationOn, forKey: "notis")
        if !UserDefaults.standard.bool(forKey: "notis") {
            UIApplication.shared.unregisterForRemoteNotifications()
        } else {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    private func performLogout() {
        userDefaultsMonitor.updateLoginStatus(false)
        router.reset()
        UIApplication.shared.unregisterForRemoteNotifications()
        matomoTracker.track(eventWithCategory: "logout button", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
        matomoTracker.startNewSession()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try? RealmManager.shared.realm.write {
                RealmManager.shared.realm.deleteAll()
                //print("Realm Delete: Success")
            }
            try? keychain.deleteItem(forKey: "jwtToken")
            try? keychain.deleteItem(forKey: "accountId")
            try? keychain.deleteItem(forKey: "mainEmail")
            UserDefaults.standard.dictionaryRepresentation().keys.forEach { key in
                if /*key != "fcmToken" &&*/ key != "userTheme" {
                    UserDefaults.standard.removeObject(forKey: key)
                    //print("Key Deleted: \(key)")
                }
            }
        }
    }

}

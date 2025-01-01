import SwiftUI
import Sentry

struct WelcomeView: View {
    @StateObject private var viewModel = OwnerViewModel()
    @StateObject private var viewModel2 = OrganizationViewModel()
    @StateObject private var viewModel3 = AccountViewModel()
    @StateObject private var userDefaultsMonitor = UserDefaultsMonitor()
    @State private var fetching = true
    @State private var showHome = false
    @State private var notificationPermissionRequested = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainTheme.ignoresSafeArea()
                
                VStack {
                    Text("Welcome")
                        .font(.custom("Montserrat-Regular", size: 15))
                        .padding()
                    Text(UserDefaults.standard.string(forKey: "mainName") ?? "")
                        .font(.custom("Montserrat-Medium", size: 20))
                        .bold()
                        .padding()
                    
                    if fetching {
                        ProgressView()
                            .frame(height: 60)
                    } else if viewModel.realmSaveSuccessful == true {
                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.green)
                            .frame(height: 60)
                    } else if viewModel.realmSaveSuccessful == false {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.orange)
                            .frame(height: 60)
                    }
                    
                    Text(statusMessage)
                        .font(.custom("Montserrat-Medium", size: 17))
                        .padding()
                        .multilineTextAlignment(.center)
                    
                    Button {
                        if buttonText == "Retry" {
                            retryDataFetch()
                        } else {
                            matomoTracker.track(eventWithCategory: "Continue Button", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                            userDefaultsMonitor.updateLoginStatus(true)
                            UserDefaults.standard.set(true, forKey: "plotChanged")
                            UserDefaults.standard.set(true, forKey: "notis")
                            UserDefaults.standard.set(1, forKey: "homePage")
                            UIApplication.shared.registerForRemoteNotifications()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showHome = true
                            }
                        }
                    } label: {
                        HStack {
                            Text(buttonText)
                                .font(.custom("Montserrat-Medium", size: 17))
                        }
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30))
                        .background(buttonGradient)
                        .cornerRadius(10)
                        .padding()
                    }
                    .disabled(fetching)
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $showHome, destination: {
            HomePageView()
        })
        .onAppear {
            setupInitialConfig()
            fetchData()
        }
    }
    
    private func setupInitialConfig() {
        UserDefaults.standard.set(Bundle.main.releaseVersionNumber, forKey: "appVersion")
        whatsNewShown = false
        matomoTracker.track(view: ["Welcome Page"])
        setUsername()
    /*    if !notificationPermissionRequested {
            requestNotificationPermissions()
            notificationPermissionRequested = true
        } */
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func requestNotificationPermissions() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                //print("✅ Notification authorization granted: \(granted)")
                if let error = error {
                    //print("❌ Notification authorization error: \(error.localizedDescription)")
                }
                // Register for remote notifications after permission is granted
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        )
    }
    
    private func fetchData() {
        fetching = true
        Task {
            await viewModel.fetchOwner(jsonQuery: [
                "filter[where][userId]": UserDefaults.standard.string(forKey: "userId") ?? "",
                "filter[include][0][relation]": "unit",
                "filter[include][1][relation]": "user",
            ])
            await viewModel2.fetchOrg(jsonQuery: [:])
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                fetching = false
            }
            await viewModel3.fetchAccounts(jsonQuery: [:])
        }
    }
    
    private func retryDataFetch() {
        viewModel.realmSaveSuccessful = nil
        fetchData()
    }
    
    private var statusMessage: String {
        if fetching {
            return "please wait while we gather your data.."
        } else if viewModel.realmSaveSuccessful == true {
            return "You're all set"
        } else if viewModel.realmSaveSuccessful == false {
            return "Some data couldn't be saved locally.\nYou can continue, but some features may be limited offline."
        } else {
            return "Processing your data..."
        }
    }
    
    private var buttonText: String {
        if fetching {
            return "Optimizing..."
        } else if viewModel.realmSaveSuccessful == true {
            return "Continue"
        } else {
            return "Retry"
        }
    }
    
    private var buttonGradient: LinearGradient {
        if fetching {
            return LinearGradient(
                colors: [.gray, .gray],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else if viewModel.realmSaveSuccessful == false {
            return LinearGradient(
                colors: [.orange, .orange.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [Color("lavender500"), Color("BluePurple")],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    func setUsername() {
        let user = User()
        user.username = UserDefaults.standard.string(forKey: "mainName") ?? ""
        user.userId = UUID().uuidString
        user.data = ["phone": UserDefaults.standard.string(forKey: "mainPhoneNumber") ?? ""]
        SentrySDK.setUser(user)
    }
}

#Preview {
    WelcomeView()
}

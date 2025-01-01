import SwiftUI
import Sentry
import FirebaseCore
import UserNotifications
import FirebaseMessaging

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        // Set messaging delegate
        Messaging.messaging().delegate = self
        
        // Request notification permissions, uncomment if you want notis perm asked at start of app(login page)
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                //print("✅ Notification authorization granted: \(granted)")
                if let error = error {
                    //print("❌ Notification authorization error: \(error.localizedDescription)")
                }
            }
        )
        // Register for remote notifications
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let jwt = try? keychain.string(forKey: "jwtToken")
        if (jwt ?? "").count < 5 {
            Messaging.messaging().apnsToken = deviceToken
            let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
            let token = tokenParts.joined()
            //print("✅ Successfully registered for remote notifications with token: \(token)")
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }
}



extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      //print("📱 Firebase registration token: \(fcmToken ?? "nil")")
        // Here you can send the token to your server if needed
       // UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
        try? keychain.set(fcmToken ?? "", forKey: "fcmToken")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        NotificationCenter.default.post(name: Notification.Name("didReceiveRemoteNotification"), object: nil, userInfo: userInfo)
        //print("📬 Received notification while app in foreground: \(userInfo)")
        completionHandler([[.banner, .list, .sound]])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        UserDefaults.standard.set(userInfo["route"] ?? "", forKey: "route")
        refresh = true
        //print("👆 User tapped on notification: \(userInfo)")
        //print("route: \(UserDefaults.standard.string(forKey: "route") ?? "")")
        NotificationCenter.default.post(name: Notification.Name("didTapRemoteNotification"), object: nil, userInfo: userInfo)
        
        completionHandler()
        
    }
}

@main
struct ProptollApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var router = Router()
    @StateObject private var viewModel = NoticeViewModel()
    @State private var showBills = false
    @State private var showReceipts = false
    @State private var showNotice = false
    
    
    init() {
        SentrySDK.start { options in
            options.dsn = "https://a3170e9cb82d1760d56d3aa9910f5ac8@o4505566808571904.ingest.us.sentry.io/4507905563164672"
            options.debug = false
            options.environment = "staging"
            options.enableAutoPerformanceTracing = true
            options.enableWatchdogTerminationTracking = false
            options.enableFileIOTracing = false
            options.tracesSampleRate = 1.0
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                ForceUpdateView2()
                    .onChange(of: viewModel.notices) { _ in
                        if viewModel.notices.count > 0 {
                            showNotice = true
                        }
                    }
                    .fullScreenCover(isPresented: $showNotice){
                        NavigationStack{
                            NewsView(notice: viewModel.notices.first, showFullNotice: $showNotice)
                                .onAppear(){
                                    UserDefaults.standard.set("", forKey: "route")
                                    //print("\(viewModel.notices.count)")
                                }
                                .navigationBarItems(leading: Button("Home") {
                                    UserDefaults.standard.set("", forKey: "route")
                                    showNotice = false
                                })
                        }
                    }
            }
            .environmentObject(router)
            .onOpenURL { url in
                Task{
                    await handleDeepLink(url)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("didTapRemoteNotification"))) { _ in
                if (UserDefaults.standard.string(forKey: "route") ?? "").count > 0
                {
                    if let deepLink = "https://consumer.proptoll.com/\(UserDefaults.standard.string(forKey: "route") ?? "")" as? String,
                       let url = URL(string: deepLink){
                        //print("received deeplink from noti \(deepLink)")
                        Task {
                            await handleDeepLink(_:url)
                        }
                    }
                    else{
                        //print("noti deeplink failed")
                    }
                }
                else
                {
                    setupRemoteNotificationObserver()
                }
            }
            .onAppear(){
                if (UserDefaults.standard.string(forKey: "route") ?? "").count > 0
                {
                    if let deepLink = "https://consumer.proptoll.com/\(UserDefaults.standard.string(forKey: "route") ?? "")" as? String,
                       let url = URL(string: deepLink){
                        //print("received deeplink from noti \(deepLink)")
                        Task {
                            await handleDeepLink(_:url)
                        }
                    }
                    else{
                        //print("noti deeplink failed")
                    }
                }
                else
                {
                    setupRemoteNotificationObserver()
                }
            }
            
        }
    }
    
    
    private func setupRemoteNotificationObserver() { //failsafe incase route doesnt get stored in UserDefaults.
        NotificationCenter.default.addObserver(forName: Notification.Name("didTapRemoteNotification"), object: nil, queue: .main) { notification in
            if let userInfo = notification.userInfo {
                //print("📬 Received remote notification in ProptollApp: \(userInfo)")
                // Handle the notification here
                if let deepLink = "https://consumer.proptoll.com/\(userInfo["route"] ?? "")" as? String,
                   let url = URL(string: deepLink){
                    //print("received deeplink from noti \(deepLink)")
                    Task {
                        await handleDeepLink(_:url)
                    }
                }
                else{
                    //print("noti deeplink failed")
                }
            }
        }
    }
    
    
    func handleDeepLink(_ url: URL) async{
        let jwt = try? keychain.string(forKey: "jwtToken")
        if (jwt ?? "").count > 5 { //basically is user is logged in then only handle deep link
        //print("🔗 Received deep link: \(url)")
        
        guard url.scheme == "https",
              url.host == "consumer.proptoll.com" else {
            //print("❌ Unhandled deep link \(url.path)")
            return
        }
        
        Task {
            let path = url.path
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let queryItems = components?.queryItems ?? []
            
            switch path {
            case "/home":
                if let subscreen = queryItems.first(where: { $0.name == "subscreen" })?.value {
                    switch subscreen {
                    case "invoices":
                        UserDefaults.standard.set(3,forKey:"homePage")
                        UserDefaults.standard.set(false,forKey:"showHome")
                    case "receipts":
                        UserDefaults.standard.set(4,forKey:"homePage")
                        UserDefaults.standard.set(false,forKey:"showHome")
                    default:
                        ()
                        //print("❌ Unknown subscreen: \(subscreen)")
                    }
                }
            case let noticePath where noticePath.hasPrefix("/notice/post/"):
                UserDefaults.standard.set(1,forKey:"homePage")
                let postId = url.lastPathComponent
                if !postId.isEmpty {
                    Task {
                        await viewModel.fetchNotices(jsonQuery: ["filter[where][id]": postId,
                                                           "filter[include][0][relation]": "noticeActivityLogs",
                                                           "filter[where][noticeStatus]": 2])
                    }
                } else {
                    //print("❌ Invalid post ID in deep link")
                }
            default:
                ()
                //print("❌ Unhandled deep link path \(path)")
            }
        }
    }
    }
}

struct NoticeView: View {
    @ObservedObject var viewModel: NoticeViewModel
    @Binding var showNotice: Bool
    var body: some View {
        ZStack {
            if viewModel.notices.isEmpty {
                ProgressView("Loading...")
            } else {
                ForEach(viewModel.notices, id: \.id) { notice in
                    NewsView(notice: notice, showFullNotice: $showNotice)
                    .onAppear() {
                        UserDefaults.standard.set("", forKey: "route")
                    }
                }
            }
        }
    }
}


// Note: You'll need to implement ContentView, Router, NoticeViewModel, NewsView, BillsView, and ReceiptsView
// as they are referenced in this code but not defined here.

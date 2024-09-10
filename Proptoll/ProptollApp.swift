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
        
        // Set messaging delegate
        Messaging.messaging().delegate = self
        
        // Request notification permissions
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                print("✅ Notification authorization granted: \(granted)")
                if let error = error {
                    print("❌ Notification authorization error: \(error.localizedDescription)")
                }
            }
        )
        
        // Register for remote notifications
        application.registerForRemoteNotifications()
        
        // Attempt to fetch FCM token
        Messaging.messaging().token { token, error in
            if let error = error {
                print("❌ Error fetching FCM token: \(error.localizedDescription)")
            } else if let token = token {
                print("✅ FCM token successfully retrieved:")
                print("📱 FCM TOKEN: \(token)")
            } else {
                print("⚠️ No FCM token retrieved and no error reported")
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        print("✅ Successfully registered for remote notifications with token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("📱 Firebase registration token: \(fcmToken ?? "nil")")
        // Here you can send the token to your server if needed
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("📬 Received notification while app in foreground: \(userInfo)")
        completionHandler([[.banner, .list, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("👆 User tapped on notification: \(userInfo)")
        NotificationCenter.default.post(name: Notification.Name("didReceiveRemoteNotification"), object: nil, userInfo: userInfo)
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
    
    /*
    init() {
        SentrySDK.start { options in
            options.dsn = "https://a3170e9cb82d1760d56d3aa9910f5ac8@o4505566808571904.ingest.us.sentry.io/4507905563164672"
            options.debug = false
            options.environment = "dev"
            options.tracesSampleRate = 1.0
        }
    }
    */
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                ContentView()
                    .fullScreenCover(isPresented: $showNotice) {
                        NavigationStack {
                            NoticeView(viewModel: viewModel)
                                .navigationBarItems(leading: Button("Home") {
                                    showNotice = false
                                    router.reset()
                                })
                        }
                    }
                    .fullScreenCover(isPresented: $showBills) {
                        NavigationStack {
                            BillsView2()
                                .navigationBarItems(leading: Button("Home") {
                                    showBills = false
                                    router.reset()
                                })
                        }
                    }
                    .fullScreenCover(isPresented: $showReceipts) {
                        NavigationStack {
                            ReceiptsView2()
                                .navigationBarItems(leading: Button("Home") {
                                    showReceipts = false
                                    router.reset()
                                })
                        }
                    }
            }
            .environmentObject(router)
            .onOpenURL { url in
                handleDeepLink(url)
            }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        print("🔗 Received deep link: \(url)")
        print("Scheme: \(url.scheme ?? "empty url scheme")")
        print("Host: \(url.host ?? "empty url host")")
        print("Last path component: \(url.lastPathComponent)")
        
        guard url.scheme == "consumer.proptoll.com",
              let host = url.host else {
            print("❌ Unhandled deep link")
            return
        }
        
        Task {
            // Reset the path before pushing the new destination
            router.reset()
            
            switch host {
            case "bills":
                showReceipts = false
                showBills = true
            case "receipts":
                showBills = false
                showReceipts = true
            default:
                showReceipts = false
                showBills = false
                if let postNumber = Int(host) {
                    await viewModel.fetchNotices(jsonQuery: ["filter[where][postNumber]": "\(postNumber)"])
                    showNotice = true
                } else {
                    print("❌ Unhandled deep link host")
                }
            }
        }
    }
}

struct NoticeView: View {
    @ObservedObject var viewModel: NoticeViewModel
    @EnvironmentObject private var router: Router
    
    var body: some View {
        ZStack {
            if viewModel.notices.isEmpty {
                ProgressView("Loading...")
            } else {
                ForEach(viewModel.notices, id: \.id) { notice in
                    NewsView(deepLink: "consumer.proptoll.com://\(notice.postNumber)",
                             title: notice.title,
                             subTitle: notice.subTitle,
                             content: notice.content,
                             image: notice.attachments?.first?.s3ResourceUrl ?? "",
                             notice: notice)
                }
            }
        }
    }
}

struct BillsView2: View {
    @EnvironmentObject private var router: Router
    
    var body: some View {
        ZStack {
            BillsView()
        }
        .navigationBarBackButtonHidden()
    }
}

struct ReceiptsView2: View {
    @EnvironmentObject private var router: Router
    
    var body: some View {
        ZStack {
            ReceiptsView()
        }
        .navigationBarBackButtonHidden()
    }
}

// Note: You'll need to implement ContentView, Router, NoticeViewModel, NewsView, BillsView, and ReceiptsView
// as they are referenced in this code but not defined here.

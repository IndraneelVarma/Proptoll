import SwiftUI
import Firebase
import FirebaseCore
import UserNotifications
import FirebaseMessaging


final class AppDelegate: NSObject, UIApplicationDelegate{
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool{
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in})
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().token { token, error in
            if let error{
                print("error fetching fcm token: \(error)")
            }
            else if let token{
                print("fcm token is: \(token)")
            }
        }
        
        return true
    }
    
    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error){
        print("failed to register for remote notis: \(error)")
    }
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        var readableToken = ""
        for index in 0 ..< deviceToken.count {
            readableToken += String(format: "%02.2hhx", deviceToken[index] as CVarArg)
        }
        print("Received an APNs devie token: \(readableToken)")
    }
}

extension AppDelegate: MessagingDelegate{
    func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebasetoken: \(fcmToken)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([[.banner, .list, .sound]])
    }
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping ()->Void)  {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(name: Notification.Name("didReceiveRemoteNotification"), object: nil, userInfo: userInfo)
        completionHandler()
    }
}

@main
struct ProptollApp: App {
    @StateObject private var router = Router()
    @StateObject private var viewModel = NoticeViewModel()
    @State private var showBills = false
    @State private var showReceipts = false
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                ContentView()
                    .navigationDestination(for: Int.self) { postNumber in
                        NoticeView(postNumber: postNumber, viewModel: viewModel)
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
        print(url.scheme ?? "empty url scheme")
        print(url.host ?? "empty url host")
        print(url.lastPathComponent)
        
        guard url.scheme == "consumer.proptoll.com",
              let host = url.host else {
            print("Unhandled deep link")
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
                    router.path.append(postNumber)
                } else {
                    print("Unhandled deep link host")
                }
            }
        }
    }
}

struct NoticeView: View {
    let postNumber: Int
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
                             image: notice.attachments?.first?.s3ResourceUrl ?? "")
                }
            }
        }
        .navigationBarTitle("Notice", displayMode: .inline)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: Button("Back") {
            router.path.removeLast()
        })
    }
}

// Placeholder views for Bills and Receipts
struct BillsView2: View {
    @EnvironmentObject private var router: Router
    var body: some View {
        ZStack{
            BillsView()
        }
        .navigationBarBackButtonHidden()
    }
}

struct ReceiptsView2: View {
    @EnvironmentObject private var router: Router
    var body: some View {
        ZStack{
            ReceiptsView()
            
        }
        .navigationBarBackButtonHidden()
        
    }
}

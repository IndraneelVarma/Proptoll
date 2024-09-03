import SwiftUI

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
                                .navigationBarItems(leading: Button("Back") {
                                    showBills = false
                                    router.reset()
                                })
                        }
                    }
                    .fullScreenCover(isPresented: $showReceipts) {
                        NavigationStack {
                            ReceiptsView2()
                                .navigationBarItems(leading: Button("Back") {
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
        
        guard url.scheme == "proptoll.com",
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
                    NewsView(deepLink: "proptoll.com://\(notice.postNumber)",
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

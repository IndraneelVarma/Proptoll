import SwiftUI

@main
struct ProptollApp: App {
    @StateObject private var router = Router()
    @StateObject private var viewModel = NoticeViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                ContentView()
                    .navigationDestination(for: Int.self) { postNumber in
                        NoticeView(postNumber: postNumber, viewModel: viewModel)
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

        guard url.scheme == "proptollStack",
              let host = url.host,
              let postNumber = Int(host) else {
            print("Unhandled deep link")
            return
        }

        Task {
            await viewModel.fetchNotices(jsonQuery: ["filter[where][postNumber]": "\(postNumber)"])
            
            // Reset the path before pushing the new destination
            router.reset()
            
            // Push the new destination
            router.path.append(postNumber)
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
                    NewsView(deepLink: "proptollStack://\(notice.postNumber)",
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

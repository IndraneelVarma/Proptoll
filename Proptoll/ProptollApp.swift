import SwiftUI

@main
struct ProptollApp: App {
    @StateObject var router = Router()
    @State private var showingNotice = false
    @StateObject var viewModel = NoticeViewModel()
    @State private var postNumber = 0

    var body: some Scene {
        WindowGroup {
            ContentView()
                .fullScreenCover(isPresented: $showingNotice) {
                    NavigationStack {
                        ZStack {
                            if viewModel.notices.isEmpty {
                                ProgressView("Loading...")
                            } else {
                                ForEach(viewModel.notices, id: \.id) { notice in
                                    NewsView(title: notice.title, subTitle: notice.subTitle, content: notice.content, image: notice.attachments?.first?.s3ResourceUrl ?? "")
                                }
                            }
                        }
                        .navigationBarTitle("Notice", displayMode: .inline)
                        .navigationBarItems(leading: Button("Back") {
                            showingNotice = false
                        })
                    }
                }
                .environmentObject(router)
                .onOpenURL(perform: { url in
                    print(url.scheme ?? "empty url scheme")
                    print(url.host ?? "empty url host")
                    print(url.lastPathComponent)
                    if url.scheme == "proptollStack" {
                        switch url.host {
                        case let host where Int(host ?? "0") != nil:
                            if let postNumber = Int(host ?? "0") {
                                Task {
                                    await viewModel.fetchNotices(jsonQuery: ["filter[where][postNumber]": "\(postNumber)"])
                                }
                                showingNotice = true
                            }
                        default:
                            print("Unhandled deep link")
                        }
                    }
                })
        }
    }
}

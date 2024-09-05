import SwiftUI

struct NewsView: View {
    var deepLink: String
    var title: String
    var subTitle: String
    var content: String
    var image: String?
    
    @State private var isSharePresented = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                Text(title.htmlToString())
                    .font(.title)
                    .multilineTextAlignment(.center)
                
                Text(subTitle.htmlToString())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                
                if let imageUrl = URL(string: image ?? "https://picsum.photos/200") {
                    AsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 300, height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300, height: 200)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300, height: 200)
                                .foregroundColor(.gray)
                        @unknown default:
                            ProgressView()
                                .frame(height: 200)
                        }
                    }
                } else {
                    //fallback if no image
                }
                
                Text(content.htmlToString())
                    .padding()
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isSharePresented = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $isSharePresented) {
            ActivityViewController(activityItems: [deepLink])
        }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}

#Preview {
    NavigationView {
        NewsView(deepLink: "https://example.com", title: "Test", subTitle: "subtitle ajdlajdafh", content: "akdhakfhkahfkjahfkjahfa akhfkjahfkahfkahfahf alfhlkahflkahflahfla ajkfgjyafhagfkag  jagfjhagfjagfh ajhgfhjafgkjagf ajfgjahfgjhagfjh", image: nil)
    }
}

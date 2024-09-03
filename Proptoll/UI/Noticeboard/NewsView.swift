import SwiftUI

struct NewsView: View {
    var deepLink: String
    var title: String
    var subTitle: String
    var content: String
    var image: String?
    
    @State private var isSharePresented = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(title.htmlToString())
                    .font(.title)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            
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
                        ProgressView()
                            .frame(height: 200)
                    @unknown default:
                        ProgressView()
                            .frame(height: 200)
                    }
                }
            } else {
                // Fallback if no image URL is available
            }
            ScrollView{
                Text(content.htmlToString())
                    .padding()
            }
            
            Spacer()
            
            Button(action: {
                isSharePresented = true
            }) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .padding()
            .sheet(isPresented: $isSharePresented) {
                ActivityViewController(activityItems: [deepLink])
            }
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
    NewsView(deepLink: "https://example.com", title: "Test", subTitle: "subtitle ajdlajdafh", content: "akdhakfhkahfkjahfkjahfa akhfkjahfkahfkahfahf alfhlkahflkahflahfla ajkfgjyafhagfkag  jagfjhagfjagfh ajhgfhjafgkjagf ajfgjahfgjhagfjh", image: nil)
}

import SwiftUI
import Zoomable

struct ZoomableImageView: View {
    let imageURL: URL
    @Binding var isPresented: Bool

    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .zoomable()
                case .failure:
                    Text("Failed to load image")
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Close") {
            isPresented = false
        })
    }
}

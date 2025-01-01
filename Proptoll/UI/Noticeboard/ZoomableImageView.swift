import SwiftUI
import Zoomable


struct ZoomableImageView: View {
    let imageURL: URL
    @Binding var isPresented: Bool
    var notice: Notice? = nil
    @Binding var selectdTab: Int
    
    init(imageURL: URL, isPresented: Binding<Bool>, notice: Notice? = nil, selectedTab: Binding<Int>) {
            self.imageURL = imageURL
            self._isPresented = isPresented
            self.notice = notice
            _selectdTab = selectedTab
        }

    var body: some View {
        GeometryReader { geometry in
            if notice?.attachments?.count ?? 0 <= 1 {
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
                        Text("Failed to load image, try another image")
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            else {
                TabView(selection: $selectdTab) {
                    ForEach(notice?.attachments ?? [], id: \.s3ResourceUrl) { attachment in
                        if let imageUrlString = attachment.s3ResourceUrl,
                           let url = URL(string: imageUrlString),
                           let index = notice?.attachments?.firstIndex(where: { $0.s3ResourceUrl == attachment.s3ResourceUrl })
                        {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(maxHeight: 400)
                                        .tint(.gray)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .zoomable()
                                case .failure:
                                    ProgressView()
                                        .frame(maxHeight: 400)
                                        .tint(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .tag(index)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: Button("Close") {
            isPresented = false
        })
    }
}

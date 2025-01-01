import SwiftUI

struct UserGuideView: View {
    @StateObject var viewModel = UserGuideViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some View {
        ZStack {
            Color.mainTheme.ignoresSafeArea()
            if networkMonitor.isConnected {
                if !viewModel.images.isEmpty {
                    TabView {
                        ForEach(viewModel.images, id: \.self) { imageName in
                            let url = URL(string: imageName.s3ResourceUrl)
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(20)
                                        .frame(width: UIScreen.main.bounds.width * 1.1, height: UIScreen.main.bounds.height * 1.1)
                                case .failure:
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                }
                else {
                    VStack{
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                            .foregroundStyle(.red)
                            .padding(.bottom, 10)
                        Text("Check your internet connection!")
                            .padding(.bottom, 10)
                    }
                }
            }
            else {
                VStack{
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                        .foregroundStyle(.red)
                        .padding(.bottom, 10)
                    Text("Check your internet connection!")
                        .padding(.bottom, 10)
                }
            }
        }
        .onAppear {
            Task{
                await viewModel.fetchPhotos(jsonQuery: [:])
            }
        }
    }
}



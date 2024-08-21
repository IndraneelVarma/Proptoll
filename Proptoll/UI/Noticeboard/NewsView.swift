//
//  NewView.swift
//  DemoCards
//
//  Created by Indraneel Varma on 07/08/24.
//

import SwiftUI

struct NewsView: View {
    @StateObject var viewModel = NoticeViewModel()
    var title: String
    var content: String
    var image: String?
    var body: some View {
        VStack{
            Text(title.htmlToString())
                .font(.title)
            
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
            Text(content.htmlToString())
                .padding()
            Spacer()
        }
    }
}



#Preview {
    NewsView(title: "Test", content: "akdhakfhkahfkjahfkjahfa akhfkjahfkahfkahfahf alfhlkahflkahflahfla ajkfgjyafhagfkag  jagfjhagfjagfh ajhgfhjafgkjagf ajfgjahfgjhagfjh", image: nil)
}

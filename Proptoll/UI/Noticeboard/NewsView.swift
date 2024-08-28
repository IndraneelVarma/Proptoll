//
//  NewView.swift
//  DemoCards
//
//  Created by Indraneel Varma on 07/08/24.
//

import SwiftUI

struct NewsView: View {
    var title: String
    var subTitle: String
    var content: String
    var image: String?
    var body: some View {
        VStack{
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
    NewsView(title: "Test", subTitle: "subtitle ajdlajdafh", content: "akdhakfhkahfkjahfkjahfa akhfkjahfkahfkahfahf alfhlkahflkahflahfla ajkfgjyafhagfkag  jagfjhagfjagfh ajhgfhjafgkjagf ajfgjahfgjhagfjh", image: nil)
}

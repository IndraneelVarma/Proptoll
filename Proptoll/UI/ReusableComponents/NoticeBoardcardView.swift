//
//  NoticeBoardcardView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 09/08/24.
//

import SwiftUI

struct NoticeBoardcardView: View {
    //let imageURL: String = ArticleData.image //for async image
    @State var title: String = ""
    @State var content: String = ""
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .center, spacing: 5) {
                HTMLView(htmlContent: ArticleData.title, extractedText: $title)
                    .frame(height: 0)
                HTMLView(htmlContent: ArticleData.content, extractedText: $content)
                    .frame(height: 0)
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                // AsyncImage part commented out
                /*
                 AsyncImage(url: imageURL) { phase in
                 switch phase {
                 case .success(let image):
                 image
                 .resizable()
                 .aspectRatio(contentMode: .fill)
                 .frame(height: 200)
                 .clipped()
                 case .failure:
                 Image(systemName: "photo")
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(height: 200)
                 case .empty:
                 ProgressView()
                 @unknown default:
                 EmptyView()
                 }
                 }
                 .cornerRadius(8)
                 */
                
                // SF Symbol image added instead
                Image(systemName: "newspaper.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 150)
                    .foregroundColor(.blue)
                    .padding()
                
                Text(content)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                
                NavigationLink("more details", destination: NewsView())
            }
            .padding()
            .frame(width: 340, height: 400)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.3), radius: 5)
        }
    }
}

#Preview {
   
        NoticeBoardcardView(title: "News Title", content: "Content")
    
}

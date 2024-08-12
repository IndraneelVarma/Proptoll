//
//  NewView.swift
//  DemoCards
//
//  Created by Indraneel Varma on 07/08/24.
//

import SwiftUI

struct NewsView: View {
    @State var article: String = ""
    let htmlContent = ArticleData.title + ArticleData.content
    var body: some View {
        HTMLView(htmlContent: htmlContent , extractedText: $article)
    }
}

#Preview {
    NewsView()
}

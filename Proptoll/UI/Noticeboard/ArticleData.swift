//
//  DummyAPI.swift
//  DemoCards
//
//  Created by Indraneel Varma on 08/08/24.
//

import Foundation

struct ArticleData {
    static var title: String = "<h1>Welcome to the Dummy Article</h1>"
    static var content: String = """
<p>This is a paragraph in the dummy article. It serves as an example of how to format text in an HTML document. The paragraph element is used to group sentences and create distinct blocks of text.</p>
    
    <h2>Section 1: Introduction</h2>
    <p>In this section, we introduce the topic of the article. This dummy article is designed to demonstrate basic HTML structure and styling.</p>
    
    <h2>Section 2: Main Content</h2>
    <p>The main content of the article goes here. This section contains multiple paragraphs to illustrate how text flows in a well-structured document. Here is an example of a hyperlink: <a href="https://www.google.com" target="_blank">Go to Google</a>.</p>
    
    <h2>Section 3: Conclusion</h2>
    <p>The conclusion summarizes the main points of the article. It's important to end with a strong closing statement that reinforces the article's message.</p>
    
    <p>Thank you for reading this dummy article. We hope you found it informative and helpful in understanding basic HTML formatting.</p>
"""
    static var image: String = "https://example.com/news-image.jpg"
}

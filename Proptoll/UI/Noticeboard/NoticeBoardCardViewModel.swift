//
//  ContentViewModel.swift
//  DemoCards
//
//  Created by Indraneel Varma on 08/08/24.
//

import Foundation
import SwiftUI
import WebKit

func extractH1Content(from html: String) -> String {
        return extractContent(from: html, using: "<h1>(.*?)</h1>")
    }
    
    func extractBodyContent(from html: String) -> String {
        return extractContent(from: html, using: "</h1>(.*?)</body>")
    }

func extractContent(from html: String, using pattern: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators) else {
            return "No match found"
        }
        
        let nsString = html as NSString
        let results = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
        
        if let match = results.first {
            let range = match.range(at: 1)
            return nsString.substring(with: range)
        } else {
            return "No match found"
        }
    }

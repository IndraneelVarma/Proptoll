import SwiftUI

extension String {
    func htmlToString() -> String {
        guard let data = self.data(using: .utf8) else {
            return self
        }
        do {
            let attributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            return attributedString.string
        } catch {
            //print("Error parsing HTML: \(error)")
            return self
        }
    }
    
    func htmlToAttributedString() -> AttributedString? {
            guard let data = self.data(using: .utf8) else {
                return nil
            }
            do {
                // Create a mutable copy of the HTML string
                var mutableHtml = self
                
                // Regular expression to find href attributes without "www."
                let regex = try NSRegularExpression(pattern: #"href=["'](?!https?://(?:www\.)?)(?!www\.)(https?://)?([^"'\s]+)["']"#, options: .caseInsensitive)
                
                // Replace matches with "www." added
                let range = NSRange(mutableHtml.startIndex..., in: mutableHtml)
                mutableHtml = regex.stringByReplacingMatches(in: mutableHtml, options: [], range: range, withTemplate: "href=\"https://www.$2\"")
                
                // Use the modified HTML string to create the NSAttributedString
                let nsAttributedString = try NSAttributedString(
                    data: mutableHtml.data(using: .utf8)!,
                    options: [.documentType: NSAttributedString.DocumentType.html,
                              .characterEncoding: String.Encoding.utf8.rawValue],
                    documentAttributes: nil
                )
                
                var attributedString = try AttributedString(nsAttributedString, including: \.uiKit)
                
                attributedString.foregroundColor = .primary
                
                attributedString.runs.forEach { run in
                    if let strokeColor = run.uiKit.strokeColor {
                        if strokeColor.cgColor.colorSpace?.model == .rgb,
                           strokeColor.cgColor.components == [0, 0, 0, 1] {
                            attributedString[run.range].foregroundColor = .primary
                        } else {
                            attributedString[run.range].foregroundColor = nil
                        }
                    }
                    
                    if let backgroundColor = run.uiKit.backgroundColor,
                       let components = backgroundColor.cgColor.components,
                       components.count == 4 && components[3] == 1 && // Check alpha is 1 first
                       ((components[0] == 0 && components[1] == 0 && components[2] == 0) || // Black
                        (components[0] == 1 && components[1] == 1 && components[2] == 1))   // White
                    {
                        attributedString[run.range].uiKit.backgroundColor = nil
                    }
                    
                    // Check and modify font size
                    if let originalFont = run.uiKit.font {
                                    // Get the original font weight
                                    let traits = originalFont.fontDescriptor.symbolicTraits
                                    let weightTrait = traits.intersection(.traitBold)
                                    
                                    // Determine the appropriate Montserrat font name based on weight
                                    let fontName = weightTrait.isEmpty ? "Montserrat-Regular" : "Montserrat-Bold"
                                    
                                    // Create new font with original weight but new size
                                    attributedString[run.range].uiKit.font = UIFont(name: fontName, size: 15)
                                }
                }
                
                return attributedString
            } catch {
                //print("Error parsing HTML: \(error)")
                return nil
            }
        }
    func htmlToAttributedString2() -> AttributedString? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        do {
            // Create a mutable copy of the HTML string
            var mutableHtml = self
            
            // Regular expression to find href attributes without "www."
            let hrefRegex = try NSRegularExpression(pattern: #"href=["'](?!https?://(?:www\.)?)(?!www\.)(https?://)?([^"'\s]+)["']"#, options: .caseInsensitive)
            
            // Replace matches with "www." added
            let range = NSRange(mutableHtml.startIndex..., in: mutableHtml)
            mutableHtml = hrefRegex.stringByReplacingMatches(in: mutableHtml, options: [], range: range, withTemplate: "href=\"https://www.$2\"")
            
            // Regular expression to find bullet points
            let bulletRegex = try NSRegularExpression(pattern: #"<li>(.*?)</li>"#, options: [.dotMatchesLineSeparators])
            
            // Replace bullet points with a custom bullet character
            mutableHtml = bulletRegex.stringByReplacingMatches(in: mutableHtml, options: [], range: range, withTemplate: "<li>• $1</li>")
            
            // Use the modified HTML string to create the NSAttributedString
            let nsAttributedString = try NSAttributedString(
                data: mutableHtml.data(using: .utf8)!,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil
            )
            
            var attributedString = try AttributedString(nsAttributedString, including: \.uiKit)
            
            // Ensure text foreground color is consistent and remove highlights
            attributedString.foregroundColor = .primary
            attributedString.runs.forEach { run in
                if let strokeColor = run.uiKit.strokeColor {
                    if strokeColor.cgColor.colorSpace?.model == .rgb,
                       strokeColor.cgColor.components == [0, 0, 0, 1] {
                        attributedString[run.range].foregroundColor = .primary
                    } else {
                        attributedString[run.range].foregroundColor = nil
                    }
                }
                
                
                if let backgroundColor = run.uiKit.backgroundColor,
                   let components = backgroundColor.cgColor.components,
                   components.count == 4 && components[3] == 1 && // Check alpha is 1 first
                   ((components[0] == 0 && components[1] == 0 && components[2] == 0) || // Black
                    (components[0] == 1 && components[1] == 1 && components[2] == 1))   // White
                {
                    attributedString[run.range].uiKit.backgroundColor = nil
                }
                
                // Ensure font size and weight are as desired
                if let originalFont = run.uiKit.font {
                    // Get the original font weight
                    let traits = originalFont.fontDescriptor.symbolicTraits
                    let weightTrait = traits.intersection(.traitBold)
                    
                    // Determine the appropriate Montserrat font name based on weight
                    let fontName = weightTrait.isEmpty ? "Montserrat-Regular" : "Montserrat-Bold"
                    
                    // Create new font with original weight but new size
                    attributedString[run.range].uiKit.font = UIFont(name: fontName, size: 15)
                }
            }
            
            return attributedString
        } catch {
            //print("Error parsing HTML: \(error)")
            return nil
        }
    }

}

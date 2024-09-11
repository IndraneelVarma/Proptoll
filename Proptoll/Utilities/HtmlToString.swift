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
            print("Error parsing HTML: \(error)")
            return self
        }
    }
    
    func htmlToAttributedString() -> AttributedString? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        do {
            let nsAttributedString = try NSAttributedString(
                data: data,
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
                
                // Check and modify font size
                if let font = run.uiKit.font, font.pointSize == 12 {
                    let newFont = font.withSize(15)
                    attributedString[run.range].uiKit.font = newFont
                }
                
                
                
            }
            
            return attributedString
        } catch {
            print("Error parsing HTML: \(error)")
            return nil
        }
    }
}

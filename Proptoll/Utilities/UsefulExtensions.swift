import Foundation
import SwiftUI

extension Dictionary where Key == String, Value == Any {
    func toUrlParameter(baseUrl: String = "notice-post") -> String {
        do {
            // Convert the dictionary to JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            
            // Convert JSON data to a string
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                // URL encode the JSON string
                if let encodedString = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    // Construct the final string
                    return "\(baseUrl)?filter=\(encodedString)"
                }
            }
        } catch {
            //print("Error converting to JSON: \(error)")
        }
        
        return "" // Return empty string if conversion fails
    }
}
extension UIDevice {
    var majorIOSVersion: Int {
        let versionString = UIDevice.current.systemVersion
        guard let majorVersion = Int(versionString.split(separator: ".").first ?? "") else {
            return 0 // Return 0 if parsing fails
        }
        return majorVersion
    }
}

extension String {
    var isValidEmail: Bool {
        let emailRegEx = #"""
        (?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])
        """#
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}

extension String {
    var containsNonNumeric: Bool {
        return self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil
    }
}

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Bundle {
    var releaseVersionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildVersionNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

extension Numeric where Self: Comparable {
    func toKString() -> String {
        let number = Double("\(self)") ?? 0
        
        // Convert to k format if number is 1000 or greater
        if number >= 1000 {
            let value = number / 1000.0
            let isWholeNumber = value.truncatingRemainder(dividingBy: 1) == 0
            let formattedValue = isWholeNumber ? String(format: "%.0f", value) : String(format: "%.1f", value)
            return "\(formattedValue)k"
        }
        
        // Return the original number as string if less than 1000
        return "\(self)"
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

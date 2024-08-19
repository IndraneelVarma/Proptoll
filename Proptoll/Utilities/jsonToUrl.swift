import Foundation

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
            print("Error converting to JSON: \(error)")
        }
        
        return "" // Return empty string if conversion fails
    }
}

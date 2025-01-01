import Foundation
import SimpleKeychain

 @MainActor
 class DashboardViewModel: ObservableObject {
     @Published var graph: Graph?
     @Published var error: String?
     
     struct RequestBody: Codable {
         let year: Int
         let accountId: String
     }
     
     func fetchGraphData(year: Int, accountId: String) async {
         error = nil
         graph = nil
         
         guard let url = URL(string: "\(baseApiUrl)mobile-dashboard") else {
             error = "Invalid URL"
             //print("Invalid URL: \(baseApiUrl)mobile-dashboard")
             return
         }
         
         let requestBody = RequestBody(year: year, accountId: accountId)
         
         guard let httpBody = try? JSONEncoder().encode(requestBody) else {
             error = "Failed to encode request body"
             //print("Failed to encode request body: \(requestBody)")
             return
         }
         
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         let jwt = try? keychain.string(forKey: "jwtToken")
         if let token = jwt, !token.isEmpty {
             request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
         } else {
             //print("No JWT token found in UserDefaults")
         }
         
         request.httpBody = httpBody
         
         // Log outgoing request
         //print("----- Outgoing Request -----")
         //print("URL: \(url)")
         //print("Method: POST")
         if let headers = request.allHTTPHeaderFields {
             //print("Headers: \(headers)")
         }
         if let bodyString = String(data: httpBody, encoding: .utf8) {
             //print("Body: \(bodyString)")
         }
         //print("----------------------------")
         
         do {
             let (data, response) = try await URLSession.shared.data(for: request)
             
             // Log incoming response
             if let httpResponse = response as? HTTPURLResponse {
                 //print("----- Response -----")
                 //print("Status Code: \(httpResponse.statusCode)")
                 if let responseString = String(data: data, encoding: .utf8) {
                     //print("Body: \(responseString)")
                 }
                 //print("-------------------")
             } else {
                 //print("No valid HTTPURLResponse received")
             }

             // Check status code for errors
             if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                 error = "Server returned status code \(httpResponse.statusCode)"
                 //print("Error: Non-2xx status code: \(httpResponse.statusCode)")
                 return
             }
             
             let decoded = try JSONDecoder().decode(Graph.self, from: data)
             self.graph = decoded
             
             // Check if empty
             if decoded.yearlyExpenses.services.isEmpty && decoded.monthlyExpenses.isEmpty {
                 error = "empty"
                 //print("Decoded graph is empty (no yearly or monthly expenses)")
             } else {
                 //print("Successfully decoded Graph data with \(decoded.monthlyExpenses.count) monthly expenses and \(decoded.yearlyExpenses.services.count) services.")
             }
             
         } catch {
             self.error = "Failed to fetch data: \(error.localizedDescription)"
             //print("----- Decoding/Error -----")
             //print("Error: \(error.localizedDescription)")
             //print("--------------------------")
             matomoTracker.track(
                 eventWithCategory: "dashboard api",
                 action: "error",
                 name: "Error: \(self.error ?? "")",
                 url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
             )
         }
     }
 }

 

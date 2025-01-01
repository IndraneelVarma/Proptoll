import Foundation

enum LoginError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError
}

class LoginViewModel: ObservableObject {
    private let baseURL = baseApiUrl
    @Published var loginResponse: LoginResponse?
    
    func login(phoneNumber: String) async throws -> LoginResponse {
        //print("DEBUG: Starting login process for phone number: \(phoneNumber)")
        
        guard let url = URL(string: "\(baseURL)/consumer/login") else {
            //print("DEBUG: Invalid URL")
            throw LoginError.invalidURL
        }
        
        //print("DEBUG: URL created successfully: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["mobile_number": phoneNumber]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        //print("DEBUG: Request created with parameters: \(parameters)")
        
        do {
            //print("DEBUG: Sending API request")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            //print("DEBUG: Received response")
            
            //print raw response data
            if let responseString = String(data: data, encoding: .utf8) {
                //print("DEBUG: Raw response data: \(responseString)")
            } else {
                //print("DEBUG: Unable to convert response data to string")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                //print("DEBUG: Invalid response type")
                throw LoginError.invalidResponse
            }
            
            //print("DEBUG: HTTP Status Code: \(httpResponse.statusCode)")
            //print("DEBUG: Response Headers: \(httpResponse.allHeaderFields)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                //print("DEBUG: Invalid status code")
                throw LoginError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            do {
                //print("DEBUG: Attempting to decode response")
                let decodedResponse = try decoder.decode(LoginResponse.self, from: data)
                //print("DEBUG: Successfully decoded response")
                //print("DEBUG: Decoded login response: \(decodedResponse)")
                
                // Store the received value in loginResponse
                DispatchQueue.main.async {
                    self.loginResponse = decodedResponse
                    UserDefaults.standard.set(self.loginResponse?.message ?? "", forKey: "key")
                }
                
                return decodedResponse
            } catch {
                //print("DEBUG: Decoding error: \(error.localizedDescription)")
                throw LoginError.decodingError
            }
        } catch let error as LoginError {
            //print("DEBUG: LoginError occurred: \(error)")
            throw error
        } catch {
            //print("DEBUG: Network error occurred: \(error.localizedDescription)")
            throw LoginError.networkError(error)
        }
    }
}

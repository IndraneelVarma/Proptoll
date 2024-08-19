import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError
}

class LoginViewModel {
    private let baseURL = baseApiUrl
    
    func login(phoneNumber: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/consumer/login") else {
            throw APIError.invalidURL
        }
        
        let body: [String: Any] = ["mobile_number": phoneNumber]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            do {
                let loginResponse = try decoder.decode(LoginResponse.self, from: data)
                return loginResponse
            } catch {
                throw APIError.decodingError
            }
        } catch {
            throw APIError.networkError(error)
        }
    }
}

import Foundation

enum LoginError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError
}

class LoginViewModel {
    private let baseURL = baseApiUrl
    
    func login(phoneNumber: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/consumer/login") else {
            throw LoginError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["mobile_number": phoneNumber]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw LoginError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            do {
                let loginResponse = try decoder.decode(LoginResponse.self, from: data)
                return loginResponse
            } catch {
                throw LoginError.decodingError
            }
        } catch let error as LoginError {
            throw error
        } catch {
            throw LoginError.networkError(error)
        }
    }
}

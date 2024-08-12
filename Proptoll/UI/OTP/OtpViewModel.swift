import Foundation

enum OtpAPIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError
}

class OtpViewModel {
    private let baseURL = "https://api.qa.proptoll.com/api/" // Replace with your actual API base URL
    
    func login(otp: String, phoneNumber: String, verificationKey: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/consumer/verifyotp") else {
            throw APIError.invalidURL
        }
        
        let body: [String: Any] = ["otp": otp,
                                   "verficationKey": verificationKey,
                                   "mobile_number": phoneNumber]
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
                let otpresponse = try decoder.decode(LoginResponse.self, from: data)
                return otpresponse
            } catch {
                throw APIError.decodingError
            }
        } catch {
            throw APIError.networkError(error)
        }
    }
}

struct OTPResponse: Codable {
    let message: String
}

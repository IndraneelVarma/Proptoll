import Foundation

enum OTPError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError
}

class OtpViewModel {
    private let baseURL = baseApiUrl
    
    func verify(otp: String, phoneNumber: String, verificationKey: String) async throws -> OTPResponse {
        let url = "\(baseURL)/consumer/verifyotp"
        let parameters: [String: Any] = [
            "otp": otp,
            "verficationKey": verificationKey,
            "mobile_number": phoneNumber
        ]
        
        return try await performRequest(url: url, parameters: parameters)
    }
    
    func resend(phoneNumber: String, message: String) async throws -> ResendResponse {
        let url = "\(baseURL)/consumer/resendotp"
        let parameters: [String: Any] = [
            "mobile_number": phoneNumber,
            "message": message
        ]
        
        return try await performRequest(url: url, parameters: parameters)
    }
    
    private func performRequest<T: Decodable>(url: String, parameters: [String: Any]) async throws -> T {
        guard let url = URL(string: url) else {
            throw OTPError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw OTPError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            do {
                let decodedResponse = try decoder.decode(T.self, from: data)
                return decodedResponse
            } catch {
                throw OTPError.decodingError
            }
        } catch let error as OTPError {
            throw error
        } catch {
            throw OTPError.networkError(error)
        }
    }
}


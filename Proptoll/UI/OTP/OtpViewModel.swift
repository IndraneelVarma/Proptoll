import Foundation

enum OtpAPIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError
}

class OtpViewModel {
    private let baseURL = "https://api.staging.proptoll.com/api" 
    
    func verify(otp: String, phoneNumber: String, verificationKey: String) async throws -> OTPResponse {
        guard let url = URL(string: "\(baseURL)/consumer/verifyotp") else {
            print("scam2")
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
                let otpresponse = try decoder.decode(OTPResponse.self, from: data)
                return otpresponse
            } catch {
                throw APIError.decodingError
            }
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func resend(phoneNumber: String, message: String) async throws -> ResendResponse {
        guard let url = URL(string: "\(baseURL)/consumer/resendotp") else {
            throw APIError.invalidURL
        }
        
        let body: [String: Any] = ["mobile_number": phoneNumber,
                                   "message": message]
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
                let resendresponse = try decoder.decode(ResendResponse.self, from: data)
                return resendresponse
            } catch {
                throw APIError.decodingError
            }
        } catch {
            throw APIError.networkError(error)
        }
    }
}



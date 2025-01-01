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
        //print("DEBUG: Starting OTP verification for phone number: \(phoneNumber)")
        let url = "\(baseURL)/consumer/verifyotp"
        let parameters: [String: Any] = [
            "otp": otp,
            "verficationKey": verificationKey,
            "mobile_number": phoneNumber
        ]
        //print("DEBUG: Verify OTP parameters: \(parameters)")
        
        return try await performRequest(url: url, parameters: parameters)
    }
    
    func resend(phoneNumber: String, message: String) async throws -> ResendResponse {
        //print("DEBUG: Starting OTP resend for phone number: \(phoneNumber)")
        let url = "\(baseURL)/consumer/resendotp"
        let parameters: [String: Any] = [
            "mobile_number": phoneNumber,
            "message": message
        ]
        //print("DEBUG: Resend OTP parameters: \(parameters)")
        
        return try await performRequest(url: url, parameters: parameters)
    }
    
    private func performRequest<T: Decodable>(url: String, parameters: [String: Any]) async throws -> T {
        //print("DEBUG: Performing request to URL: \(url)")
        
        guard let url = URL(string: url) else {
            //print("DEBUG: Invalid URL")
            throw OTPError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        //print("DEBUG: Request created with parameters: \(parameters)")
        
        do {
            //print("DEBUG: Sending API request")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            //print("DEBUG: Received response")
            
             
            if let responseString = String(data: data, encoding: .utf8) {
                //print("DEBUG: Raw response data: \(responseString)")
            } else {
                //print("DEBUG: Unable to convert response data to string")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                //print("DEBUG: Invalid response type")
                throw OTPError.invalidResponse
            }
            
            //print("DEBUG: HTTP Status Code: \(httpResponse.statusCode)")
            //print("DEBUG: Response Headers: \(httpResponse.allHeaderFields)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                //print("DEBUG: Invalid status code")
                throw OTPError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            do {
                //print("DEBUG: Attempting to decode response")
                let decodedResponse = try decoder.decode(T.self, from: data)
                //print("DEBUG: Successfully decoded response")
                //print("DEBUG: Decoded response: \(decodedResponse)")
                return decodedResponse
            } catch {
                //print("DEBUG: Decoding error: \(error.localizedDescription)")
                throw OTPError.decodingError
            }
        } catch let error as OTPError {
            //print("DEBUG: OTPError occurred: \(error)")
            throw error
        } catch {
            //print("DEBUG: Network error occurred: \(error.localizedDescription)")
            throw OTPError.networkError(error)
        }
    }
}

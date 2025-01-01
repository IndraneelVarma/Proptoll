import Foundation
import SimpleKeychain

enum APIError: Error {
    case networkError(Error)
    case decodingError(DecodingError)
    case invalidStatusCode(Int)
    case unknownError(Error)
    case invalidURL
    case invalidResponse
    case encodingError

    var localizedDescription: String {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .encodingError:
            return "Encoding error"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .invalidStatusCode(let statusCode):
            return "Invalid status code: \(statusCode)"
        case .unknownError(let error):
            return "Unknown error: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        }
    }
}

class MainApiCall {
    private let baseURL = URL(string: baseApiUrl)!
    private let session: URLSession
    private let httpMethod: String
    
    
    init(session: URLSession = .shared, httpMethod: String) {
        self.session = session
        self.httpMethod = httpMethod
        //print("🚀 Initialized API Client with base URL: \(baseURL)")
    }
    
    func getData<T: Codable>(endpoint: String, jsonQuery: [String: Any]) async throws -> T {
        //print("\n📡 API Call Started: \(endpoint)")
        //print("📤 Query Parameters:", jsonQuery)
        
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint),
                                          resolvingAgainstBaseURL: true) else {
            //print("❌ Invalid URL construction")
            throw APIError.invalidURL
        }

        if !endpoint.contains("pdf") {
            components.queryItems = jsonQuery.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }

        guard let url = components.url else {
            //print("❌ Failed to construct URL")
            throw APIError.invalidURL
        }
        
        //print("🌐 Full URL:", url.absoluteString)

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        let jwt = try? keychain.string(forKey: "jwtToken")
        let token = jwt ?? ""
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        //print("📋 Headers:", request.allHTTPHeaderFields ?? [:])

        do {
            let (data, response) = try await session.data(for: request)
            //print("📥 Received Response")
            
            // Print raw response data regardless of what happens next
            if let jsonString = String(data: data, encoding: .utf8) {
                //print("📦 Raw Response Data:", jsonString)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                //print("❌ Invalid response type")
                throw APIError.invalidResponse
            }
            
            //print("📊 Status Code:", httpResponse.statusCode)

            guard (200...299).contains(httpResponse.statusCode) else {
                //print("❌ Invalid status code:", httpResponse.statusCode)
                throw APIError.invalidStatusCode(httpResponse.statusCode)
            }

            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                //print("✅ Successfully decoded response")
                return decodedResponse
            } catch let error as DecodingError {
                //print("❌ Decoding Error:", error)
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            //print("❌ API Error:", error.localizedDescription)
            throw error
        } catch {
            //print("❌ Network Error:", error.localizedDescription)
            throw APIError.networkError(error)
        }
    }

    func getData2<T: Codable>(endpoint: String, jsonQuery: [String: Any]) async throws -> T {
        //print("\n📡 API Call Started (getData2): \(endpoint)")
        //print("📤 Query Parameters:", jsonQuery)
        
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint),
                                          resolvingAgainstBaseURL: true) else {
            //print("❌ Invalid URL construction")
            throw APIError.invalidURL
        }
        
        components.queryItems = jsonQuery.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        
        guard let url = components.url else {
            //print("❌ Failed to construct URL")
            throw APIError.invalidURL
        }
        
        //print("🌐 Full URL:", url.absoluteString)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let jwt = try? keychain.string(forKey: "jwtToken")
        let token = jwt ?? ""
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        //print("📋 Headers:", request.allHTTPHeaderFields ?? [:])
        
        do {
            let (data, response) = try await session.data(for: request)
            //print("📥 Received Response")
            
            // Print raw response data regardless of what happens next
            if let jsonString = String(data: data, encoding: .utf8) {
                //print("📦 Raw Response Data:", jsonString)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                //print("❌ Invalid response type")
                throw APIError.invalidResponse
            }
            
            //print("📊 Status Code:", httpResponse.statusCode)
            
            guard (200...299).contains(httpResponse.statusCode) else {
                //print("❌ Invalid status code:", httpResponse.statusCode)
                throw APIError.invalidStatusCode(httpResponse.statusCode)
            }
            
            do {
                let decodedResponse = try snakeCaseDecoder.decode(T.self, from: data)
                //print("✅ Successfully decoded response with snake case decoder")
                return decodedResponse
            } catch let error as DecodingError {
                //print("❌ Decoding Error:", error)
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            //print("❌ API Error:", error.localizedDescription)
            throw error
        } catch {
            //print("❌ Network Error:", error.localizedDescription)
            throw APIError.networkError(error)
        }
    }
    
    func getData3(endpoint: String, body: [String: Any]) async throws -> Data {
        //print("\n📡 API Call Started (getData3): \(endpoint)")
        //print("📤 Request Body:", body)
        
        guard let components = URLComponents(url: baseURL.appendingPathComponent(endpoint),
                                          resolvingAgainstBaseURL: true) else {
            //print("❌ Invalid URL construction")
            throw APIError.invalidURL
        }
        
        guard let url = components.url else {
            //print("❌ Failed to construct URL")
            throw APIError.invalidURL
        }
        
        //print("🌐 Full URL:", url.absoluteString)
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jwt = try? keychain.string(forKey: "jwtToken")
        let token = jwt ?? ""
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        //print("📋 Headers:", request.allHTTPHeaderFields ?? [:])
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            //print("📤 Encoded Request Body:", String(data: jsonData, encoding: .utf8) ?? "")
        } catch {
            //print("❌ JSON Encoding Error:", error)
            throw APIError.encodingError
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            //print("📥 Received Response")
            
            // Print raw response data regardless of what happens next
            if let jsonString = String(data: data, encoding: .utf8) {
                //print("📦 Raw Response Data:", jsonString)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                //print("❌ Invalid response type")
                throw APIError.invalidResponse
            }
            
            //print("📊 Status Code:", httpResponse.statusCode)
            
            guard (200...299).contains(httpResponse.statusCode) else {
                //print("❌ Invalid status code:", httpResponse.statusCode)
                throw APIError.invalidStatusCode(httpResponse.statusCode)
            }
            
            //print("✅ Successfully received data")
            return data
        } catch let error as APIError {
            //print("❌ API Error:", error.localizedDescription)
            throw error
        } catch {
            //print("❌ Network Error:", error.localizedDescription)
            throw APIError.networkError(error)
        }
    }

    // Create a JSONDecoder with snake case to camel case key decoding strategy
    let snakeCaseDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

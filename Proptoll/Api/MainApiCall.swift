import Foundation
import Combine

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
    }
    
    func getData<T: Codable>(endpoint: String, jsonQuery: [String: Any]) async -> AnyPublisher<T, APIError> {
        //print("Debug: getData called with endpoint: \(endpoint)")
        //print("Debug: jsonQuery: \(jsonQuery)")

        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: true) else {
            //print("Error: Invalid URL components")
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        if !endpoint.contains("pdf") {
            components.queryItems = jsonQuery.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            //print("Debug: Query items: \(components.queryItems ?? [])")
        } else {
            //print("Debug: PDF endpoint detected, not adding query items")
        }

        guard let url = components.url else {
            //print("Error: Unable to create URL from components")
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        //print("Debug: Constructed URL: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
        //print("Debug: Request method: \(httpMethod)")
        //print("Debug: Request headers: \(request.allHTTPHeaderFields ?? [:])")

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                //print("Debug: Received response")
                guard let httpResponse = response as? HTTPURLResponse else {
                    //print("Error: Invalid response type")
                    throw APIError.invalidResponse
                }
                //print("Debug: Response status code: \(httpResponse.statusCode)")
                //print("Debug: Response headers: \(httpResponse.allHeaderFields)")

                guard (200...299).contains(httpResponse.statusCode) else {
                    //print("Error: Invalid status code \(httpResponse.statusCode)")
                    throw APIError.invalidStatusCode(httpResponse.statusCode)
                }

                //print("Debug: Received \(data.count) bytes")
                if let responseString = String(data: data, encoding: .utf8) {
                    //print("Debug: Response body: \(responseString.prefix(1000))...") // Print first 1000 characters to avoid overwhelming logs
                } else {
                    //print("Debug: Unable to convert response data to string")
                }

                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    //print("Debug: APIError occurred: \(apiError)")
                    return apiError
                } else if let decodingError = error as? DecodingError {
                    //print("Debug: Decoding error occurred: \(decodingError)")
                    return .decodingError(decodingError)
                } else {
                    //print("Debug: Network error occurred: \(error.localizedDescription)")
                    return .networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    func getData2<T: Codable>(endpoint: String, jsonQuery: [String: Any]) async -> AnyPublisher<T, APIError> {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: true) else {
            //print("Error: Invalid base URL or endpoint")
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        components.queryItems = jsonQuery.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        
        guard let url = components.url else {
            //print("Error: Failed to create URL from components")
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        //print("Request URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
        //print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                //print("Received response for endpoint: \(endpoint)")
                guard let httpResponse = response as? HTTPURLResponse else {
                    //print("Error: Invalid response type")
                    throw APIError.invalidResponse
                }
                //print("Response Status Code: \(httpResponse.statusCode)")
                //print("Response Headers: \(httpResponse.allHeaderFields)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    //print("Error: Invalid status code \(httpResponse.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        //print("Response Body: \(responseString)")
                    }
                    throw APIError.invalidStatusCode(httpResponse.statusCode)
                }
                
                //print("Received Data Size: \(data.count) bytes")
                if endpoint == "bills" {
                    if let responseString = String(data: data, encoding: .utf8) {
                        //print("Bills Response: \(responseString)")
                    } else {
                        //print("Unable to convert bills response to string")
                    }
                }
                
                return data
            }
            .decode(type: T.self, decoder: snakeCaseDecoder)
            .mapError { error -> APIError in
                //print("Error occurred: \(error.localizedDescription)")
                if let apiError = error as? APIError {
                    return apiError
                } else if let decodingError = error as? DecodingError {
                    //print("Decoding Error: \(decodingError)")
                    return .decodingError(decodingError)
                } else {
                    return .networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func getData3(endpoint: String, body: [String: Any]) async -> AnyPublisher<Data, APIError> {
        //print("Debug: getData3 called with endpoint: \(endpoint)")
        //print("Debug: Request body: \(body)")
        
        guard let components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: true) else {
            //print("Error: Invalid URL components")
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        guard let url = components.url else {
            //print("Error: Unable to create URL from components")
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        //print("Debug: Constructed URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
        //print("Debug: Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            //print("Debug: Request body serialized successfully. Size: \(jsonData.count) bytes")
        } catch {
            //print("Error: Failed to serialize request body. Error: \(error.localizedDescription)")
            return Fail(error: APIError.encodingError).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                //print("Debug: Received response")
                guard let httpResponse = response as? HTTPURLResponse else {
                    //print("Error: Invalid response type")
                    throw APIError.invalidResponse
                }
                //print("Debug: Response status code: \(httpResponse.statusCode)")
                //print("Debug: Response headers: \(httpResponse.allHeaderFields)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    //print("Error: Invalid status code \(httpResponse.statusCode)")
                    throw APIError.invalidStatusCode(httpResponse.statusCode)
                }
                
                //print("Debug: Received \(data.count) bytes")
                if let responseString = String(data: data, encoding: .utf8) {
                    //print("Debug: Response body: \(responseString)")
                } else {
                    //print("Debug: Unable to convert response data to string")
                }
                
                return data
            }
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    //print("Debug: APIError occurred: \(apiError)")
                    return apiError
                } else {
                    //print("Debug: Network error occurred: \(error.localizedDescription)")
                    return .networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    

    // Create a JSONDecoder with snake case to camel case key decoding strategy
    let snakeCaseDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}



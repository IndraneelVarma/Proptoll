import Foundation
import Combine

enum APIError: Error {
    case networkError(Error)
    case decodingError(DecodingError)
    case invalidStatusCode(Int)
    case unknownError(Error)
    case invalidURL
    case invalidResponse

    var localizedDescription: String {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
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
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func getData<T: Codable>(endpoint: String, jsonQuery: [String: Any]) -> AnyPublisher<T, APIError> {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: true) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        components.queryItems = jsonQuery.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        
        guard let url = components.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.invalidStatusCode(httpResponse.statusCode)
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    return apiError
                } else if let decodingError = error as? DecodingError {
                    return .decodingError(decodingError)
                } else {
                    return .networkError(error)
                }
            }
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.printDebugInfo(url: url, method: "GET", parameters: jsonQuery, headers: ["Authorization": "Bearer \(jwtToken)"])
            })
            .eraseToAnyPublisher()
    }
    
    private func printDebugInfo(url: URL, method: String, parameters: [String: Any], headers: [String: String]) {
        print("Debug: Full API URL - \(url.absoluteString)")
        print("Debug: HTTP Method - \(method)")
        print("Debug: Parameters - \(parameters)")
        print("Debug: Headers - \(headers)")
    }
}

// Example usage:
// let apiCall = MainApiCall()
// let cancellable = apiCall.getData<YourResponseType>(endpoint: "your/endpoint", jsonQuery: ["key": "value"])
//     .sink(receiveCompletion: { completion in
//         switch completion {
//         case .finished:
//             print("Request completed successfully")
//         case .failure(let error):
//             print("Request failed with error: \(error.localizedDescription)")
//         }
//     }, receiveValue: { response in
//         print("Received response: \(response)")
//     })

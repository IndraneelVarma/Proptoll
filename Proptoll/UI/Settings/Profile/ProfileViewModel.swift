import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var profile: [Profile] = []
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: ProfileApiService
    
    init(apiService: ProfileApiService = ProfileApiService()) {
        self.apiService = apiService
    }
    
    func fetchProfile(authToken: String) {
        apiService.getProfile(authToken: authToken, limit: 1)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = error.localizedDescription
                }
            } receiveValue: { profile in
                self.profile = profile
            }
            .store(in: &cancellables)
    }
}

class ProfileApiService {
    private let baseURL = URL(string: baseApiUrl)!
    
    func getProfile(authToken: String, limit: Int) -> AnyPublisher<[Profile], Error> {
        var components = URLComponents(url: baseURL.appendingPathComponent("plots"), resolvingAgainstBaseURL: true)
        components?.queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        
        guard let url = components?.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Profile].self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}

import Foundation
import Combine

class NoticeViewModel: ObservableObject {
    @Published var notices: [Notice] = []
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: NoticeApiService
    
    init(apiService: NoticeApiService = NoticeApiService()) {
        self.apiService = apiService
    }
    
    func fetchNotices(authToken: String, limit: Int, orderItem: String, order: String) {
        apiService.getNotices(authToken: authToken, limit: limit, orderItem: orderItem, order: order)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = error.localizedDescription
                }
            } receiveValue: { notices in
                self.notices = notices
            }
            .store(in: &cancellables)
    }
}

class NoticeApiService {
    private let baseURL = URL(string: baseApiUrl)!
    
    func getNotices(authToken: String, limit: Int, orderItem: String, order: String) -> AnyPublisher<[Notice], Error> {
        let fullUrl = URL(string: "\(baseURL)/notice-post?filter=%7B%0A%22order%22%3A%20%22\(orderItem)%20\(order)%22%2C%0A%20%20%22limit%22%3A%20\(limit)%0A%7D")
        guard let url = fullUrl else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        //debugging
        print("Debug: Full API URL - \(request.url?.absoluteString ?? "Unknown URL")")
                print("Debug: HTTP Method - \(request.httpMethod ?? "Unknown Method")")
                print("Debug: Headers - \(request.allHTTPHeaderFields ?? [:])")
        
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Notice].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

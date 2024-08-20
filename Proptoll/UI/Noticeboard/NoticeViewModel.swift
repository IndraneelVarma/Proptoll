import Foundation
import Combine

class NoticeViewModel: ObservableObject {
    @Published var notices: [Notice] = []
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall()) {
        self.apiService = apiService
    }
    
    func fetchNotices(jsonQuery: [String: Any]) {
        apiService.getData(endpoint: "notice-post", jsonQuery: jsonQuery)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (notices: [Notice]) in
                self?.notices = notices
            }
            .store(in: &cancellables)
    }
}

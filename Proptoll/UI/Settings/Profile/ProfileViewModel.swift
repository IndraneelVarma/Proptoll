import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var profile: [Profile] = []
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "GET")) {
        self.apiService = apiService
    }
    
    func fetchProfile(jsonQuery: [String: Any]) async {
        await apiService.getData2(endpoint: "plots", jsonQuery: jsonQuery)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (profile: [Profile]) in
                self?.profile = profile
                
            }
            .store(in: &cancellables)
    }
}

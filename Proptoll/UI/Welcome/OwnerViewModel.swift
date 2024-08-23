import Foundation
import Combine

class OwnerViewModel: ObservableObject {
    @Published var owners: [Owner] = []
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall()) {
        self.apiService = apiService
    }
    
    func fetchBills(jsonQuery: [String: Any]) async {
        await apiService.getData2(endpoint: "owners", jsonQuery: jsonQuery)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (owner: [Owner]) in
                self?.owners = owner
                
            }
            .store(in: &cancellables)
    }
}

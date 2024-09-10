import Foundation
import Combine

class OwnerViewModel: ObservableObject {
    @Published var owners: [Owner] = []
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "GET")) {
        self.apiService = apiService
    }
    
    func fetchOwner(jsonQuery: [String: Any]) async {
        await apiService.getData2(endpoint: "owners", jsonQuery: jsonQuery)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                    matomoTracker.track(eventWithCategory: "owners/welcome api", action: "error", name: "Error: \(self?.error ?? "")" ,url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                }
            } receiveValue: { [weak self] (owner: [Owner]) in
                DispatchQueue.main.async{
                    self?.owners = owner
                }
                UserDefaults.standard.setValue(owner.first?.plots?.first?.id, forKey: "plotId")
                print("ViewModel Plot Id: \(plotId)")
            }
            .store(in: &cancellables)
    }
}

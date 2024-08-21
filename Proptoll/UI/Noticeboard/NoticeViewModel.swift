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
    
    func fetchNotices(jsonQuery: [String: Any]) async {
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
                print(notices.count)
            }
            .store(in: &cancellables)
    }
    func filteredNotices(searchText: String) async {
        if !searchText.isEmpty {
            let jsonQuery: [String: Any]
            let check = searchText.allSatisfy{ $0.isNumber }
            if check{
                jsonQuery = [
                    "filter[order]": "id DESC",
                    "filter[limit]": 100,
                    "filter[offset]": 0,
                    "filter[where][postNumber]": searchText,
                ]
            }
            else{
                jsonQuery = [
                    "filter[order]": "id DESC",
                    "filter[limit]": 100,
                    "filter[offset]": 0,
                    "filter[where][title][like]": searchText,
                ]
            }
            self.notices.removeAll()
            await fetchNotices(jsonQuery: jsonQuery)
            print(notices.count)
        }
    }
}

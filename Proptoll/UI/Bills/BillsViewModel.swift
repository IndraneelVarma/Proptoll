import Foundation
import Combine

class BillsViewModel: ObservableObject {
    @Published var bills: [Bill] = []
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall()) {
        self.apiService = apiService
    }
    
    func fetchBills(jsonQuery: [String: Any]) async {
        await apiService.getData2(endpoint: "bills", jsonQuery: jsonQuery)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (bills: [Bill]) in
                self?.bills = bills
                
            }
            .store(in: &cancellables)
    }
    func filteredBills(searchText: String) async { //useless for now, might be of use when we add search
        if !searchText.isEmpty {
            let jsonQuery: [String: Any]
            let check = searchText.allSatisfy{ $0.isNumber }
            if check{
                jsonQuery = [
                    "filter[order]": "id DESC",
                    "filter[limit]": 50,
                    "filter[offset]": 0,
                    "filter[where][postNumber]": searchText,
                ]
            }
            else{
                jsonQuery = [
                    "filter[order]": "id DESC",
                    "filter[limit]": 50,
                    "filter[offset]": 0,
                    "filter[where][title][like]": searchText,
                ]
            }
            self.bills.removeAll()
            await fetchBills(jsonQuery: jsonQuery)
           
        }
    }
}

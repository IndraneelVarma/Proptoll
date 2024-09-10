import Foundation
import Combine

class BillsViewModel: ObservableObject {
    @Published var bills: [Bill] = []
    @Published var error: String?
    @Published var billUrl: PDF?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "GET")) {
        self.apiService = apiService
    }
    
    func fetchBills(jsonQuery: [String: Any]) async {
        print("fetchBills Called")
         await apiService.getData2(endpoint: "bills", jsonQuery: jsonQuery)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                    matomoTracker.track(eventWithCategory: "bills api", action: "error", name: "Error: \(self?.error ?? "")" ,url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                }
            } receiveValue: { [weak self] (bills: [Bill]) in
                DispatchQueue.main.async{
                    self?.bills = bills
                }
                if let limit = jsonQuery["filter[limit]"] as? Int{
                    if limit == 1
                    {
                        UserDefaults.standard.setValue(bills.first?.id, forKey: "billId")
                        print("Limit 1 and bill id \(billId)")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func downloadBills(jsonQuery: [String: Any], billId2: String) async{
        await apiService.getData(endpoint: "generate-pdf/bill/\(billId2)", jsonQuery: jsonQuery)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (url: PDF) in
                DispatchQueue.main.async{
                    self?.billUrl = url
                }
                print(self?.billUrl?.URL ?? "")
                
            }
            .store(in: &cancellables)
        
    }
    
}

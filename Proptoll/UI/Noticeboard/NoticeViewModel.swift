import Foundation

@MainActor
class NoticeViewModel: ObservableObject {
    @Published var notices: [Notice] = []
    @Published var error: String?
    
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "GET")) {
        self.apiService = apiService
    }
    
    func fetchNotices(jsonQuery: [String: Any]) async {
        error = nil
        
        do {
            let fetchedNotices: [Notice] = try await apiService.getData(
                endpoint: "notice-post",
                jsonQuery: jsonQuery
            )
            
            self.notices = fetchedNotices
            if self.notices.isEmpty {
                self.error = "empty"
            }
            
        } catch {
            self.error = error.localizedDescription
            matomoTracker.track(
                eventWithCategory: "notice api",
                action: "error",
                name: "Error: \(self.error ?? "")",
                url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
            )
        }
    }
    
    func fetchMoreNotices(jsonQuery: [String: Any]) async {
        do {
            let newNotices: [Notice] = try await apiService.getData(
                endpoint: "notice-post",
                jsonQuery: jsonQuery
            )
            
            self.notices.append(contentsOf: newNotices)
            
        } catch {
            self.error = error.localizedDescription
            matomoTracker.track(
                eventWithCategory: "notice api",
                action: "error",
                name: "Error: \(self.error ?? "")",
                url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
            )
        }
    }
    
    func filteredNotices(searchText: String) async {
        guard !searchText.isEmpty else { return }
        
        let jsonQuery: [String: Any]
        let check = searchText.allSatisfy { $0.isNumber }
        
        if check {
            jsonQuery = [
                "filter[order]": "id DESC",
                "filter[limit]": 20,
                "filter[offset]": 0,
                "filter[where][postNumber]": searchText,
                "filter[include][0][relation]": "noticeActivityLogs",
                "filter[where][noticeStatus]": 2
            ]
        } else {
            let searchText2 = searchText.trimmingCharacters(in: .whitespaces)
            let searchText3 = searchText2.capitalized
            jsonQuery = [
                "filter[order]": "id DESC",
                "filter[limit]": 20,
                "filter[offset]": 0,
                "filter[where][or][0][title][like]": searchText2,
                "filter[where][or][1][subTitle][like]": searchText2,
                "filter[where][or][2][title][like]": searchText3,
                "filter[where][or][3][subTitle][like]": searchText3,
                "filter[include][0][relation]": "noticeActivityLogs",
                "filter[where][noticeStatus]": 2
            ]
        }
        
        clearNotices()
        await fetchNotices(jsonQuery: jsonQuery)
    }
    
    func clearNotices() {
        self.notices.removeAll()
    }
}

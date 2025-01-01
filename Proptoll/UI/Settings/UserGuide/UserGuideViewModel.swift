import Foundation

@MainActor
class UserGuideViewModel: ObservableObject {
    @Published var images: [UserGuide] = []
    @Published var error: String?
    
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "GET")) {
        self.apiService = apiService
    }
    
    func fetchPhotos(jsonQuery: [String: Any]) async {
        do {
            let userGuideImages: [UserGuide] = try await apiService.getData2(
                endpoint: "bucket/userguide",
                jsonQuery: jsonQuery
            )
            
            self.images = userGuideImages
            
        } catch {
            self.error = error.localizedDescription
            matomoTracker.track(
                eventWithCategory: "profile api",
                action: "error",
                name: "Error: \(self.error ?? "")",
                url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
            )
        }
    }
}

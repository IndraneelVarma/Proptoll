import Foundation
import RealmSwift
import SwiftUI

@MainActor
class OwnerViewModel: ObservableObject {
    @Published var owners: [Owner] = []
    @Published var error: String?
    @Published var realmSaveSuccessful: Bool?  // nil = not attempted, true = success, false = failure
    @StateObject private var userDefaultsMonitor = UserDefaultsMonitor()
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "GET")) {
        self.apiService = apiService
        //print("ViewModel initialized")
        logRealmLocation()
    }
    
    private func logRealmLocation() {
        if let realmURL = Realm.Configuration.defaultConfiguration.fileURL {
            //print("Realm file location: \(realmURL)")
        }
    }
    
    func fetchOwner(jsonQuery: [String: Any]) async {
        //print("fetchOwner called with query: \(jsonQuery)")
        
        // Reset state
        error = nil
        realmSaveSuccessful = nil
        //print("Reset state for new fetch")
        
        do {
            //print("Starting API request")
            let owners: [Owner] = try await apiService.getData2(
                endpoint: "mobile-owners",
                jsonQuery: jsonQuery
            )
            
            //print("Received \(owners.count) owners from API")
            await handleOwnerResponse(owners)
            
        } catch {
            //print("API request failed with error: \(error)")
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        self.error = error.localizedDescription
        matomoTracker.track(
            eventWithCategory: "owners/welcome api",
            action: "error",
            name: "Error: \(self.error ?? "")",
            url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
        )
    }
    
    private func handleOwnerResponse(_ owners: [Owner]) async {
        logFirstOwnerDetails(owners)
        
        //print("Processing owners")
        self.owners = owners
        await saveToRealm(owners)
        updateUserDefaults(owners)
    }
    
    private func logFirstOwnerDetails(_ owners: [Owner]) {
        if let firstOwner = owners.first {
            //print("First owner details - ID: \(firstOwner.id), Has unit: \(firstOwner.unit != nil)")
        }
    }
    
    private func saveToRealm(_ owners: [Owner]) async {
        //print("Starting Realm storage process")
        
        do {
            let realm = try await Realm()
            //print("Successfully accessed Realm instance")
            
            try realm.write {
                //print("Beginning Realm write transaction")
                
                for owner in owners {
                    saveOwnerToRealm(owner, realm: realm)
                }
                
                //print("Completed Realm write transaction")
            }
            
            await verifyRealmStorage(realm)
            self.realmSaveSuccessful = true
            
        } catch {
            await handleRealmError(error)
        }
    }
    
    private func saveOwnerToRealm(_ owner: Owner, realm: Realm) {
        //print("Processing owner: \(owner.id)")
        
        let realmOwner = OwnerRealm(owner: owner)
        realm.add(realmOwner, update: .modified)
        //print("Saved owner: \(owner.id) to Realm")
        
        if let unit = owner.unit {
            //print("Processing unit for owner \(owner.id)")
            let realmUnit = UnitRealm(unit: unit)
            realm.add(realmUnit, update: .modified)
            //print("Saved unit: \(unit.id) to Realm")
        }
    }
    
    private func verifyRealmStorage(_ realm: Realm) async {
        let savedOwners = realm.objects(OwnerRealm.self)
        //print("Verification - Found \(savedOwners.count) owners in Realm")
        savedOwners.forEach { owner in
            //print("Saved owner ID: \(owner.id), Has unit: \(owner.unit != nil)")
        }
    }
    
    private func handleRealmError(_ error: Error) async {
        //print("❌ Realm error: \(error)")
        //print("Error description: \(error.localizedDescription)")
        if let realmError = error as? RealmError {
            //print("Realm specific error: \(realmError.localizedDescription)")
        }
        self.realmSaveSuccessful = false
    }
    
    private func updateUserDefaults(_ owners: [Owner]) {
        guard let firstOwner = owners.first else { return }
        
        if !UserDefaults.standard.bool(forKey: "userLoggedIn") {
            //print("Setting up first-time user defaults")
           // UserDefaults.standard.setValue(firstOwner.user?.email, forKey: "mainEmail")
            try? keychain.set(firstOwner.user?.email ?? "", forKey: "mainEmail")
            if let unitNumber = firstOwner.unit?.unitNumber {
                UserDefaults.standard.setValue(unitNumber, forKey: "unitNumber")
            }
        }
        
        UserDefaults.standard.setValue(true, forKey: "userLoggedIn")
        UserDefaults.standard.setValue(firstOwner.id, forKey: "ownerId")
        UserDefaults.standard.setValue(owners.count, forKey: "ownerCount")
        //print("owners count: \(owners.count)")
        userDefaultsMonitor.updateSelectedUnitId(firstOwner.unit?.id ?? "")
        UserDefaults.standard.set(firstOwner.unit?.unitNumber, forKey: "selectedUnitNumber")
        //print("UserDefaults updated successfully")
    }
}

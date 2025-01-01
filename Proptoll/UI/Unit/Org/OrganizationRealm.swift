import SwiftUI
import RealmSwift


class OrganizationRealm: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var organizationName: String
    @Persisted var addressLine1: String
    @Persisted var addressLine2: String
    @Persisted var city: String
    @Persisted var state: String
    @Persisted var postalCode: String
    @Persisted var country: String
    @Persisted var contactNo: String
    
    convenience init(organization: Organization) {
        self.init()
        self.organizationName = organization.organizationName
        self.addressLine1 = organization.addressLine1
        self.addressLine2 = organization.addressLine2
        self.city = organization.city
        self.state = organization.state
        self.postalCode = organization.postalCode
        self.country = organization.country
        self.contactNo = organization.contactNo
    }
    
    func toModel() -> Organization {
        return Organization(
            organizationName: self.organizationName,
            addressLine1: self.addressLine1,
            addressLine2: self.addressLine2,
            city: self.city,
            state: self.state,
            postalCode: self.postalCode,
            country: self.country,
            contactNo: self.contactNo
        )
    }
}


class OrgRealmManager: ObservableObject {
    public var realm: Realm
    @Published var organizations: [OrganizationRealm] = []
    
    init() {
        // Configure Realm
        
        let key = try? keychain.data(forKey: "privateKey")
        
        let config = Realm.Configuration(
            encryptionKey: key,
            schemaVersion: 1, // Increment this when your schema changes
            deleteRealmIfMigrationNeeded: true // This will delete data instead of migrating
        )
        Realm.Configuration.defaultConfiguration = config
        
        // Initialize Realm
        do {
            realm = try Realm()
        } catch {
            // Delete Realm files if initialization fails
            if let realmURL = Realm.Configuration.defaultConfiguration.fileURL {
                let realmURLs = [
                    realmURL,
                    realmURL.appendingPathExtension("lock"),
                    realmURL.appendingPathExtension("note"),
                    realmURL.appendingPathExtension("management")
                ]
                
                for url in realmURLs {
                    try? FileManager.default.removeItem(at: url)
                }
                
                // Try initializing again after deletion
                do {
                    realm = try Realm()
                } catch {
                    fatalError("Failed to initialize Realm after cleanup: \(error)")
                }
            } else {
                fatalError("Failed to initialize Realm: \(error)")
            }
        }
        
        // Load initial data
        fetchOrganizations()
    }
    
    // MARK: - Read Operations
    
    func fetchOrganizations() {
        let results = realm.objects(OrganizationRealm.self)
        organizations = Array(results)
    }
    
    func getOrganization(byId id: String) -> OrganizationRealm? {
        return realm.object(ofType: OrganizationRealm.self, forPrimaryKey: id)
    }
    
    // MARK: - Write Operations
    
    func addOrganization(_ organization: Organization) {
        let realmOrg = OrganizationRealm(organization: organization)
        do {
            try realm.write {
                realm.add(realmOrg)
            }
            fetchOrganizations()
        } catch {
            //print("Error adding organization: \(error)")
        }
    }
    
    func updateOrganization(_ organization: Organization, id: String) {
        do {
            if let realmOrg = realm.object(ofType: OrganizationRealm.self, forPrimaryKey: id) {
                try realm.write {
                    realmOrg.organizationName = organization.organizationName
                    realmOrg.addressLine1 = organization.addressLine1
                    realmOrg.addressLine2 = organization.addressLine2
                    realmOrg.city = organization.city
                    realmOrg.state = organization.state
                    realmOrg.postalCode = organization.postalCode
                    realmOrg.country = organization.country
                    realmOrg.contactNo = organization.contactNo
                }
                fetchOrganizations()
            }
        } catch {
            //print("Error updating organization: \(error)")
        }
    }
    
    func deleteOrganization(id: String) {
        do {
            if let orgToDelete = realm.object(ofType: OrganizationRealm.self, forPrimaryKey: id) {
                try realm.write {
                    realm.delete(orgToDelete)
                }
                fetchOrganizations()
            }
        } catch {
            //print("Error deleting organization: \(error)")
        }
    }
    
    func deleteAllOrganizations() {
        do {
            try realm.write {
                realm.delete(realm.objects(OrganizationRealm.self))
            }
            fetchOrganizations()
        } catch {
            //print("Error deleting all organizations: \(error)")
        }
    }
    
    // MARK: - Convenience Methods
    
    func organizationExists(withName name: String) -> Bool {
        return realm.objects(OrganizationRealm.self)
            .filter("organizationName == %@", name)
            .first != nil
    }
    
    func searchOrganizations(query: String) -> [OrganizationRealm] {
        let predicate = NSPredicate(
            format: "organizationName CONTAINS[cd] %@ OR city CONTAINS[cd] %@ OR state CONTAINS[cd] %@",
            query, query, query
        )
        let results = realm.objects(OrganizationRealm.self).filter(predicate)
        return Array(results)
    }
}

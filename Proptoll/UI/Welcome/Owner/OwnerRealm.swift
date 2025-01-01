import Foundation
import RealmSwift
import Security

// MARK: - Realm Models
class OwnerRealm: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var unitId: String
    @Persisted var userId: String
    @Persisted var isActive: Bool
    @Persisted var noOfFloors: Int
    @Persisted var createdAt: String
    @Persisted var updatedAt: String
    @Persisted var organizationId: Int
    @Persisted var unit: UnitRealm?
    @Persisted var user: UserDetailsRealm?
    @Persisted var account: AccountRealm?
    @Persisted var customProperties = List<CustomPropertiesRealm>()
    
    convenience init(owner: Owner) {
        self.init()
        self.id = owner.id
        self.unitId = owner.unitId
        self.userId = owner.userId
        self.noOfFloors = owner.noOfFloors
        self.isActive = owner.isActive
        self.createdAt = owner.createdAt
        self.updatedAt = owner.updatedAt
        self.organizationId = owner.organizationId
        
        if let ownerUnit = owner.unit {
            self.unit = UnitRealm(unit: ownerUnit)
        }
        
        if let ownerUser = owner.user {
            self.user = UserDetailsRealm(userDetails: ownerUser)
        }
        
        if let ownerAccount = owner.account {
            self.account = AccountRealm(account: ownerAccount)
        }
        
        if let properties = owner.customProperties {
            let realmProperties = properties.map { CustomPropertiesRealm(properties: $0) }
            self.customProperties.append(objectsIn: realmProperties)
        }
    }
    
    func toModel() -> Owner {
        return Owner(
            id: self.id,
            unitId: self.unitId,
            userId: self.userId,
            noOfFloors: self.noOfFloors,
            isActive: self.isActive,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            organizationId: self.organizationId,
            unit: self.unit?.toModel(),
            user: self.user?.toModel(),
            account: self.account?.toModel(),
            customProperties: Array(self.customProperties.map { $0.toModel() })
        )
    }
}

class AccountRealm: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var unitsId: String
    
    convenience init(account: AccountId) {
        self.init()
        self.id = account.id
        self.unitsId = account.unitsId
    }
    
    func toModel() -> AccountId {
        return AccountId(
            id: self.id,
            unitsId: self.unitsId
        )
    }
}

class CustomPropertiesRealm: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var value: String  // Store as string representation
    
    convenience init(properties: CustomProperties) {
        self.init()
        self.id = properties.id
        self.name = properties.name
        self.value = properties.value.stringValue
    }
    
    func toModel() -> CustomProperties {
        return CustomProperties(
            name: self.name,
            value: CustomValue.fromString(self.value)
        )
    }
}

class UserDetailsRealm: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var username: String
    @Persisted var mobileNumber: String
    @Persisted var email: String?
    @Persisted var name: String
    
    convenience init(userDetails: UserDetails) {
        self.init()
        self.id = userDetails.id
        self.username = userDetails.username
        self.mobileNumber = userDetails.mobileNumber
        self.email = userDetails.email
        self.name = userDetails.name
    }
    
    func toModel() -> UserDetails {
        return UserDetails(
            id: self.id,
            username: self.username,
            mobileNumber: self.mobileNumber,
            email: self.email,
            name: self.name
        )
    }
}

class UnitRealm: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var unitNumber: String
    @Persisted var unitType: String
    @Persisted var isCompoundUnit: Bool
    @Persisted var isAvailable: Bool
    @Persisted var statusCode: Int
    @Persisted var organizationId: Int
    
    convenience init(unit: Unit) {
        self.init()
        self.id = unit.id
        self.unitNumber = unit.unitNumber
        self.unitType = unit.unitType
        self.isCompoundUnit = unit.isCompoundUnit
        self.isAvailable = unit.isAvailable
        self.statusCode = unit.statusCode
        self.organizationId = unit.organizationId
    }
    
    func toModel() -> Unit {
        return Unit(
            id: self.id,
            unitNumber: self.unitNumber,
            unitType: self.unitType,
            isCompoundUnit: self.isCompoundUnit,
            isAvailable: self.isAvailable,
            statusCode: self.statusCode,
            organizationId: self.organizationId
        )
    }
}

// MARK: - Realm Manager
class RealmManager {
    static let shared = RealmManager()
    public var realm: Realm
    
    private init() {
        // Configure Realm
        
        let key = try? keychain.data(forKey: "privateKey")
        
        let config = Realm.Configuration(
            encryptionKey: key, schemaVersion: 1, // Increment this when your schema changes
            deleteRealmIfMigrationNeeded: true
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
    }
    
    // MARK: - Create Operations
    func saveOwner(_ owner: Owner) throws {
        let realmOwner = OwnerRealm(owner: owner)
        try realm.write {
            realm.add(realmOwner, update: .modified)
        }
    }
    
    func saveUnit(_ unit: Unit, forOwnerId ownerId: String) throws {
        guard let owner = realm.object(ofType: OwnerRealm.self, forPrimaryKey: ownerId) else {
            throw RealmError.ownerNotFound
        }
        
        let realmUnit = UnitRealm(unit: unit)
        try realm.write {
            owner.unit = realmUnit
        }
    }
    
    func saveUserDetails(_ userDetails: UserDetails, forOwnerId ownerId: String) throws {
        guard let owner = realm.object(ofType: OwnerRealm.self, forPrimaryKey: ownerId) else {
            throw RealmError.ownerNotFound
        }
        
        let realmUserDetails = UserDetailsRealm(userDetails: userDetails)
        try realm.write {
            owner.user = realmUserDetails
        }
    }
    
    // MARK: - Read Operations
    func getAllOwners() -> [Owner] {
        return realm.objects(OwnerRealm.self).map { $0.toModel() }
    }
    
    func getOwner(byId id: String) -> Owner? {
        return realm.object(ofType: OwnerRealm.self, forPrimaryKey: id)?.toModel()
    }
    
    func getUnit(forOwnerId id: String) -> Unit? {
        guard let owner = realm.object(ofType: OwnerRealm.self, forPrimaryKey: id) else {
            return nil
        }
        return owner.unit?.toModel()
    }
    
    func getUserDetails(forOwnerId id: String) -> UserDetails? {
        guard let owner = realm.object(ofType: OwnerRealm.self, forPrimaryKey: id) else {
            return nil
        }
        return owner.user?.toModel()
    }
    
    // MARK: - Update Operations
    func updateOwner(_ owner: Owner) throws {
        try saveOwner(owner)
    }
    
    func updateUnit(_ unit: Unit, forOwnerId ownerId: String) throws {
        guard let owner = realm.object(ofType: OwnerRealm.self, forPrimaryKey: ownerId) else {
            throw RealmError.ownerNotFound
        }
        
        try realm.write {
            owner.unit = UnitRealm(unit: unit)
        }
    }
    
    func updateUserDetails(_ userDetails: UserDetails, forOwnerId ownerId: String) throws {
        guard let owner = realm.object(ofType: OwnerRealm.self, forPrimaryKey: ownerId) else {
            throw RealmError.ownerNotFound
        }
        
        try realm.write {
            owner.user = UserDetailsRealm(userDetails: userDetails)
        }
    }
    
    // MARK: - Delete Operations
    func deleteOwner(withId id: String) throws {
        guard let owner = realm.object(ofType: OwnerRealm.self, forPrimaryKey: id) else {
            throw RealmError.ownerNotFound
        }
        
        try realm.write {
            realm.delete(owner)
        }
    }
    
    func deleteUnit(fromOwnerId ownerId: String) throws {
        guard let owner = realm.object(ofType: OwnerRealm.self, forPrimaryKey: ownerId) else {
            throw RealmError.ownerNotFound
        }
        
        try realm.write {
            owner.unit = nil
        }
    }
    
    func deleteUserDetails(fromOwnerId ownerId: String) throws {
        guard let owner = realm.object(ofType: OwnerRealm.self, forPrimaryKey: ownerId) else {
            throw RealmError.ownerNotFound
        }
        
        try realm.write {
            owner.user = nil
        }
    }
    
    // MARK: - Query Operations
    func searchOwners(byName name: String) -> [Owner] {
        return realm.objects(OwnerRealm.self)
            .filter("user.name CONTAINS[c] %@", name)
            .map { $0.toModel() }
    }
    
    func searchUnits(byUnitNumber unitNumber: String) -> [Unit] {
        return realm.objects(UnitRealm.self)
            .filter("unitNumber CONTAINS[c] %@", unitNumber)
            .map { $0.toModel() }
    }
    
    func searchOwners(byUsername username: String) -> [Owner] {
        return realm.objects(OwnerRealm.self)
            .filter("user.username CONTAINS[c] %@", username)
            .map { $0.toModel() }
    }
    
    func searchOwners(byEmail email: String) -> [Owner] {
        return realm.objects(OwnerRealm.self)
            .filter("user.email CONTAINS[c] %@", email)
            .map { $0.toModel() }
    }
    
    func searchOwners(byPhoneNumber phoneNumber: String) -> [Owner] {
        return realm.objects(OwnerRealm.self)
            .filter("user.mobileNumber CONTAINS[c] %@", phoneNumber)
            .map { $0.toModel() }
    }
    
    func getOwner(byUnitId unitId: String) -> Owner? {
        return realm.objects(OwnerRealm.self)
            .filter("unitId == %@", unitId)
            .first?
            .toModel()
    }
}

extension RealmManager {
    func saveAccount(_ account: AccountId, forOwnerId ownerId: String) throws {
        guard let owner = realm.object(ofType: OwnerRealm.self, forPrimaryKey: ownerId) else {
            throw RealmError.ownerNotFound
        }
        
        let realmAccount = AccountRealm(account: account)
        try realm.write {
            owner.account = realmAccount
        }
    }
    
    func getAccount(forOwnerId id: String) -> AccountId? {
        guard let owner = realm.object(ofType: OwnerRealm.self, forPrimaryKey: id) else {
            return nil
        }
        return owner.account?.toModel()
    }
    
    func updateAccount(_ account: AccountId, forOwnerId ownerId: String) throws {
        guard let owner = realm.object(ofType: OwnerRealm.self, forPrimaryKey: ownerId) else {
            throw RealmError.ownerNotFound
        }
        
        try realm.write {
            owner.account = AccountRealm(account: account)
        }
    }
    
    func deleteAccount(fromOwnerId ownerId: String) throws {
        guard let owner = realm.object(ofType: OwnerRealm.self, forPrimaryKey: ownerId) else {
            throw RealmError.ownerNotFound
        }
        
        try realm.write {
            owner.account = nil
        }
    }
}

enum RealmError: Error {
    case ownerNotFound
    case plotNotFound
    case unitNotFound
    case userNotFound
    
    var localizedDescription: String {
        switch self {
        case .ownerNotFound:
            return "Owner not found in database"
        case .plotNotFound:
            return "Plot not found in database"
        case .unitNotFound:
            return "Unit not found in database"
        case .userNotFound:
            return "User not found in database"
        }
    }
}

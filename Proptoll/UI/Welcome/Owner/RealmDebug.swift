import Foundation
import RealmSwift

class RealmDebugManager {
    static let shared = RealmDebugManager()
    
    func diagnoseRealmIssues() {
        //print("\n=== REALM DIAGNOSIS START ===")
        
        // Check default Realm configuration
        if let defaultURL = Realm.Configuration.defaultConfiguration.fileURL {
            //print("\nDefault Realm URL: \(defaultURL)")
            checkRealmFileStatus(at: defaultURL)
        } else {
            //print("❌ No default Realm URL configured")
        }
        
        // Check directory permissions
        if let realmURL = Realm.Configuration.defaultConfiguration.fileURL {
            let directoryURL = realmURL.deletingLastPathComponent()
            checkDirectoryPermissions(at: directoryURL)
        }
        
        // Try creating a test Realm
        createTestRealm()
        
        //print("\n=== REALM DIAGNOSIS END ===")
    }
    
    private func checkRealmFileStatus(at url: URL) {
        let fileManager = FileManager.default
        
        //print("\nChecking Realm files:")
        let realmURLs = [
            url,
            url.appendingPathExtension("lock"),
            url.appendingPathExtension("note"),
            url.appendingPathExtension("management")
        ]
        
        for fileURL in realmURLs {
            if fileManager.fileExists(atPath: fileURL.path) {
                do {
                    let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                    //print("✅ Found: \(fileURL.lastPathComponent)")
                    //print("   Size: \(attributes[.size] ?? 0) bytes")
                    //print("   Created: \(attributes[.creationDate] ?? "Unknown")")
                } catch {
                    //print("❌ Error reading \(fileURL.lastPathComponent): \(error)")
                }
            } else {
                //print("❌ Missing: \(fileURL.lastPathComponent)")
            }
        }
    }
    
    private func checkDirectoryPermissions(at url: URL) {
        let fileManager = FileManager.default
        
        //print("\nChecking directory permissions:")
        //print("Directory: \(url.path)")
        
        do {
            let resourceValues = try url.resourceValues(forKeys: [.isWritableKey])
            //print("✅ Directory writable: \(resourceValues.isWritable)")
        } catch {
            //print("❌ Error checking directory permissions: \(error)")
        }
        
        // Test write permissions
        let testFile = url.appendingPathComponent("realm_test_file")
        do {
            try "test".write(to: testFile, atomically: true, encoding: .utf8)
            try fileManager.removeItem(at: testFile)
            //print("✅ Write test successful")
        } catch {
            //print("❌ Write test failed: \(error)")
        }
    }
    
    private func createTestRealm() {
        //print("\nTesting Realm creation:")
        
        let config = Realm.Configuration(
            fileURL: URL.documentsDirectory.appendingPathComponent("test.realm"),
            schemaVersion: 1,
            deleteRealmIfMigrationNeeded: true
        )
        
        do {
            let realm = try Realm(configuration: config)
            //print("✅ Test Realm created successfully")
            //print("   Location: \(config.fileURL?.path ?? "Unknown")")
        } catch {
            //print("❌ Test Realm creation failed: \(error)")
            if let nsError = error as NSError? {
                //print("   Error code: \(nsError.code)")
                //print("   Description: \(nsError.localizedDescription)")
                //print("   Underlying error: \(nsError.userInfo)")
            }
        }
    }
    
    func recoverRealm() {
        //print("\n=== ATTEMPTING REALM RECOVERY ===")
        
        guard let defaultURL = Realm.Configuration.defaultConfiguration.fileURL else {
            //print("❌ No default Realm URL configured")
            return
        }
        
        let fileManager = FileManager.default
        let realmURLs = [
            defaultURL,
            defaultURL.appendingPathExtension("lock"),
            defaultURL.appendingPathExtension("note"),
            defaultURL.appendingPathExtension("management")
        ]
        
        // 1. Delete existing Realm files
        for url in realmURLs {
            do {
                if fileManager.fileExists(atPath: url.path) {
                    try fileManager.removeItem(at: url)
                    //print("✅ Deleted: \(url.lastPathComponent)")
                }
            } catch {
                //print("❌ Failed to delete \(url.lastPathComponent): \(error)")
            }
        }
        
        // 2. Create new configuration
        let newConfig = Realm.Configuration(
            fileURL: defaultURL,
            schemaVersion: 1,
            deleteRealmIfMigrationNeeded: true,
            shouldCompactOnLaunch: { totalBytes, usedBytes in
                let oneHundredMB = 100 * 1024 * 1024
                return (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5
            }
        )
        
        // 3. Try to create new Realm
        do {
            Realm.Configuration.defaultConfiguration = newConfig
            let realm = try Realm()
            //print("✅ New Realm created successfully")
            //print("   Location: \(realm.configuration.fileURL?.path ?? "Unknown")")
        } catch {
            //print("❌ Failed to create new Realm: \(error)")
        }
        
        //print("=== RECOVERY ATTEMPT COMPLETE ===\n")
    }
}

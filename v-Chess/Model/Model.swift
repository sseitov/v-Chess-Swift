//
//  Model.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 13.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import AFNetworking
import SDWebImage

let refreshUserNotification = Notification.Name("REFRESH_USER_LIST")

func currentUser() -> User? {
    if let firUser = FIRAuth.auth()?.currentUser {
        if let user = Model.shared.getUser(firUser.uid) {
            if user.socialType == .email {
                return (firUser.isEmailVerified || testUser(user.email!)) ? user : nil
            } else {
                return user;
            }
        } else {
            return nil;
        }
    } else {
        return nil
    }
}

func testUser(_ user:String) -> Bool {
    return user == "user1@test.ru" || user == "user2@test.ru"
}

func generateUDID() -> String {
    return UUID().uuidString
}

class Model: NSObject {
    
    static let shared = Model()
    
    private override init() {
        super.init()
    }
    
    // MARK: - CoreData stack
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "vChessModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("vChessModel.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            print("CoreData data error: \(error)")
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print("Saved data error: \(error)")
            }
        }
    }
    
    // MARK: - SignOut from cloud
    
    func signOut(_ completion: @escaping() -> ()) {
        let ref = FIRDatabase.database().reference()
        currentUser()!.token = nil
        currentUser()!.available = NSNumber(booleanLiteral: false)
        updateUser(currentUser()!)
        ref.child("tokens").child(currentUser()!.uid!).removeValue(completionBlock: { _, _ in
            switch currentUser()!.socialType {
            case .google:
                GIDSignIn.sharedInstance().signOut()
            case .facebook:
                FBSDKLoginManager().logOut()
            default:
                break
            }
            try? FIRAuth.auth()?.signOut()
            self.newTokenRefHandle = nil
            self.updateTokenRefHandle = nil
            self.newUserRefHandle = nil
            self.updateUserRefHandle = nil
            UserDefaults.standard.removeObject(forKey: "fbToken")
            completion()
        })
    }
    // MARK: - Cloud observers
    
    func startObservers() {
        if newTokenRefHandle == nil {
            observeTokens()
        }
        if newUserRefHandle == nil {
            observeUsers()
        }
    }
    
    lazy var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: firStorage)
    
    private var newTokenRefHandle: FIRDatabaseHandle?
    private var updateTokenRefHandle: FIRDatabaseHandle?
    
    private var newUserRefHandle: FIRDatabaseHandle?
    private var updateUserRefHandle: FIRDatabaseHandle?
    
    // MARK: - User table
    
    func createUser(_ uid:String) -> User {
        var user = getUser(uid)
        if user == nil {
            user = NSEntityDescription.insertNewObject(forEntityName: "User", into: managedObjectContext) as? User
            user!.uid = uid
        }
        return user!
    }
    
    func getUser(_ uid:String) -> User? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "uid = %@", uid)
        if let user = try? managedObjectContext.fetch(fetchRequest).first as? User {
            return user
        } else {
            return nil
        }
    }
    
    func deleteUser(_ uid:String) {
        if let user = getUser(uid) {
            self.managedObjectContext.delete(user)
            self.saveContext()
        }
    }
    
    func uploadUser(_ uid:String, result: @escaping(User?) -> ()) {
        if let existingUser = getUser(uid) {
            result(existingUser)
        } else {
            let ref = FIRDatabase.database().reference()
            ref.child("users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
                if let userData = snapshot.value as? [String:Any] {
                    let user = self.createUser(uid)
                    user.setData(userData, completion: {
                        self.getUserToken(uid, token: { token in
                            user.token = token
                            self.saveContext()
                            result(user)
                        })
                    })
                } else {
                    result(nil)
                }
            })
        }
    }
    
    func updateUser(_ user:User) {
        saveContext()
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(user.uid!).setValue(user.getData())
    }
    
    fileprivate func getUserToken(_ uid:String, token: @escaping(String?) -> ()) {
        let ref = FIRDatabase.database().reference()
        ref.child("tokens").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if let result = snapshot.value as? String {
                token(result)
            } else {
                token(nil)
            }
        })
    }
    
    func publishToken(_ user:FIRUser,  token:String) {
        let ref = FIRDatabase.database().reference()
        ref.child("tokens").child(user.uid).setValue(token)
    }
    
    fileprivate func observeTokens() {
        let ref = FIRDatabase.database().reference()
        let tokensQuery = ref.child("tokens").queryLimited(toLast:25)
        
        newTokenRefHandle = tokensQuery.observe(.childAdded, with: { (snapshot) -> Void in
            if let user = self.getUser(snapshot.key) {
                if let token = snapshot.value as? String {
                    user.token = token
                    self.saveContext()
                    NotificationCenter.default.post(name: refreshUserNotification, object: nil)
                }
            }
        })
        
        updateTokenRefHandle = tokensQuery.observe(.childChanged, with: { (snapshot) -> Void in
            if let user = self.getUser(snapshot.key) {
                if let token = snapshot.value as? String {
                    user.token = token
                    self.saveContext()
                    NotificationCenter.default.post(name: refreshUserNotification, object: nil)
                }
            }
        })
    }
    
    fileprivate func observeUsers() {
        let ref = FIRDatabase.database().reference()
        let usersQuery = ref.child("users").queryLimited(toLast:25)
        
        newUserRefHandle = usersQuery.observe(.childAdded, with: { (snapshot) -> Void in
            if self.getUser(snapshot.key) == nil, let userData = snapshot.value as? [String : Any] {
                let user = self.createUser(snapshot.key)
                user.setData(userData, completion: {
                    self.getUserToken(snapshot.key, token: { token in
                        user.token = token
                        self.saveContext()
                        NotificationCenter.default.post(name:refreshUserNotification, object: nil)
                    })
                })
            }
        })
        
        updateUserRefHandle = usersQuery.observe(.childChanged, with: { (snapshot) -> Void in
            if let user = self.getUser(snapshot.key), let userData = snapshot.value as? [String : Any] {
                if let available = userData["available"] as? Bool {
                    user.available = NSNumber(booleanLiteral: available)
                    self.saveContext()
                    NotificationCenter.default.post(name: refreshUserNotification, object: nil)
                }
            }
        })
    }
    
    func createEmailUser(_ user:FIRUser, email:String, nick:String, image:UIImage, result: @escaping(NSError?) -> ()) {
        let cashedUser = createUser(user.uid)
        cashedUser.email = email
        cashedUser.name = nick
        cashedUser.available = NSNumber(booleanLiteral: true)
        cashedUser.accountType = NSNumber(integerLiteral: SocialType.email.rawValue)
        cashedUser.avatar = UIImagePNGRepresentation(image) as NSData?
        saveContext()
        let meta = FIRStorageMetadata()
        meta.contentType = "image/png"
        self.storageRef.child(generateUDID()).put(cashedUser.avatar as! Data, metadata: meta, completion: { metadata, error in
            if error != nil {
                result(error as NSError?)
            } else {
                cashedUser.avatarURL = metadata!.path!
                self.updateUser(cashedUser)
                result(nil)
            }
        })
    }
    
    func createFacebookUser(_ user:FIRUser, profile:[String:Any], completion: @escaping() -> ()) {
        let cashedUser = createUser(user.uid)
        cashedUser.accountType = NSNumber(integerLiteral: SocialType.facebook.rawValue)
        cashedUser.email = profile["email"] as? String
        cashedUser.name = profile["name"] as? String
        cashedUser.available = NSNumber(booleanLiteral: true)
        if let picture = profile["picture"] as? [String:Any] {
            if let data = picture["data"] as? [String:Any] {
                cashedUser.avatarURL = data["url"] as? String
            }
        }
        if cashedUser.avatarURL != nil, let url = URL(string: cashedUser.avatarURL!) {
            SDWebImageDownloader.shared().downloadImage(with: url, options: [], progress: { _ in}, completed: { _, data, error, _ in
                if data != nil {
                    cashedUser.avatar = data as NSData?
                }
                self.updateUser(cashedUser)
                completion()
            })
        } else {
            cashedUser.avatar = nil
            updateUser(cashedUser)
            completion()
        }
    }
    
    func createGoogleUser(_ user:FIRUser, googleProfile: GIDProfileData!, completion: @escaping() -> ()) {
        let cashedUser = createUser(user.uid)
        cashedUser.accountType = NSNumber(integerLiteral: SocialType.google.rawValue)
        cashedUser.email = googleProfile.email
        cashedUser.name = googleProfile.name
        cashedUser.available = NSNumber(booleanLiteral: true)
        if googleProfile.hasImage {
            if let url = googleProfile.imageURL(withDimension: 100) {
                cashedUser.avatarURL = url.absoluteString
            }
        }
        if cashedUser.avatarURL != nil, let url = URL(string: cashedUser.avatarURL!) {
            SDWebImageDownloader.shared().downloadImage(with: url, options: [], progress: { _ in}, completed: { _, data, error, _ in
                if data != nil {
                    cashedUser.avatar = data as NSData?
                }
                self.updateUser(cashedUser)
                completion()
            })
        } else {
            cashedUser.avatar = nil
            updateUser(cashedUser)
            completion()
        }
    }

    func available() -> [User] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let pred1 = NSPredicate(format: "any uid != %@", currentUser()!.uid!)
        let pred2 = NSPredicate(format: "available != nil")
        let pred3 = NSPredicate(format: "available == true")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pred1, pred2, pred3])
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        if let all = try? managedObjectContext.fetch(fetchRequest) as! [User] {
            return all
        } else {
            return []
        }
    }
    
    func notAvailable() -> [User] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let pred1 = NSPredicate(format: "any uid != %@", currentUser()!.uid!)
        let pred21 = NSPredicate(format: "available == nil")
        let pred22 = NSPredicate(format: "available == false")
        let pred2 = NSCompoundPredicate(orPredicateWithSubpredicates: [pred21, pred22])
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pred1, pred2])
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        if let all = try? managedObjectContext.fetch(fetchRequest) as! [User] {
            return all
        } else {
            return []
        }
    }
}

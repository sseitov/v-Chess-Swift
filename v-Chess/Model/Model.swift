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
let inviteGameNotification = Notification.Name("INVITE_GAME")
let updateGameNotification = Notification.Name("UPDATE_GAME")
let deleteGameNotification = Notification.Name("UPDATE_GAME")

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

func isSoundEnabled() -> Bool {
    return UserDefaults.standard.bool(forKey: "enableSound")
}

func setSoundEnabled(_ enabled:Bool) {
    UserDefaults.standard.set(enabled, forKey: "enableSound")
    UserDefaults.standard.synchronize()
}

func chessDepth() -> Depth {
    let boolVal = UserDefaults.standard.bool(forKey: "ChessDepth")
    return boolVal ? .Strong : .Fast
}

func setChessDepth(_ depth:Bool) {
    UserDefaults.standard.set(depth, forKey: "ChessDepth")
    UserDefaults.standard.synchronize()
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
        let modelURL = Bundle.main.url(forResource: "v-Chess", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("v-Chess.sqlite")
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
        currentUser()?.setAvailability(false)
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
            self.newAvailableRefHandle = nil
            self.updateAvailableRefHandle = nil
            UserDefaults.standard.removeObject(forKey: "fbToken")
            completion()
        })
    }
    // MARK: - Cloud observers
    
    func startObservers() {
        if newTokenRefHandle == nil {
            observeTokens()
        }
        if newAvailableRefHandle == nil {
            observeAvailable()
        }
        if newUserRefHandle == nil {
            observeUsers()
        }
    }
    
    lazy var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: firStorage)
    
    private var newTokenRefHandle: FIRDatabaseHandle?
    private var updateTokenRefHandle: FIRDatabaseHandle?
    
    private var newUserRefHandle: FIRDatabaseHandle?

    private var newAvailableRefHandle: FIRDatabaseHandle?
    private var updateAvailableRefHandle: FIRDatabaseHandle?
    
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
    
    fileprivate func observeAvailable() {
        let ref = FIRDatabase.database().reference()
        let availableQuery = ref.child("available").queryLimited(toLast:25)
        
        newAvailableRefHandle = availableQuery.observe(.childAdded, with: { (snapshot) -> Void in
            if let user = self.getUser(snapshot.key) {
                if let available = snapshot.value as? Bool {
                    user.available = available
                    self.saveContext()
                    NotificationCenter.default.post(name: refreshUserNotification, object: user)
                }
            }
        })
        
        updateAvailableRefHandle = availableQuery.observe(.childChanged, with: { (snapshot) -> Void in
            if let user = self.getUser(snapshot.key) {
                if let available = snapshot.value as? Bool {
                    user.available = available
                    self.saveContext()
                    NotificationCenter.default.post(name: refreshUserNotification, object: user)
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
    }
    
    func createEmailUser(_ user:FIRUser, email:String, nick:String, image:UIImage, result: @escaping(NSError?) -> ()) {
        let cashedUser = createUser(user.uid)
        cashedUser.email = email
        cashedUser.name = nick
        cashedUser.accountType = Int16(SocialType.email.rawValue)
        cashedUser.avatar = UIImagePNGRepresentation(image) as NSData?
        saveContext()
        let meta = FIRStorageMetadata()
        meta.contentType = "image/png"
        self.storageRef.child(generateUDID()).put(cashedUser.avatar as! Data, metadata: meta, completion: { metadata, error in
            if error != nil {
                result(error as NSError?)
            } else {
                cashedUser.avatarURL = metadata!.path!
                cashedUser.setAvailability(true)
                self.updateUser(cashedUser)
                result(nil)
            }
        })
    }
    
    func createFacebookUser(_ user:FIRUser, profile:[String:Any], completion: @escaping() -> ()) {
        let cashedUser = createUser(user.uid)
        cashedUser.accountType = Int16(SocialType.facebook.rawValue)
        cashedUser.email = profile["email"] as? String
        cashedUser.name = profile["name"] as? String
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
                cashedUser.setAvailability(true)
                self.updateUser(cashedUser)
                completion()
            })
        } else {
            cashedUser.avatar = nil
            cashedUser.setAvailability(true)
            updateUser(cashedUser)
            completion()
        }
    }
    
    func createGoogleUser(_ user:FIRUser, googleProfile: GIDProfileData!, completion: @escaping() -> ()) {
        let cashedUser = createUser(user.uid)
        cashedUser.accountType = Int16(SocialType.google.rawValue)
        cashedUser.email = googleProfile.email
        cashedUser.name = googleProfile.name
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
                cashedUser.setAvailability(true)
                self.updateUser(cashedUser)
                completion()
            })
        } else {
            cashedUser.avatar = nil
            cashedUser.setAvailability(true)
            updateUser(cashedUser)
            completion()
        }
    }

    func availableUsers(_ available:Bool) -> [User] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let pred1 = NSPredicate(format: "any uid != %@", currentUser()!.uid!)
        let pred2 = NSPredicate(format: "available == %@", available as CVarArg)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pred1, pred2])
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        if let all = try? managedObjectContext.fetch(fetchRequest) as! [User] {
            return all
        } else {
            return []
        }
    }
    
    // MARK: - Game Push notifications
    
    enum GamePush:Int {
        case invite = 1
        case accept = 2
        case reject = 3
        case turn = 4
        case surrender = 5
    }

    
    private func vchessError(_ text:String) -> NSError {
        return NSError(domain: "v-Chess", code: -1, userInfo: [NSLocalizedDescriptionKey:text])
    }

    fileprivate lazy var httpManager:AFHTTPSessionManager = {
        let manager = AFHTTPSessionManager(baseURL: URL(string: "https://fcm.googleapis.com/fcm/"))
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue("key=\(pushServerKey)", forHTTPHeaderField: "Authorization")
        manager.responseSerializer = AFHTTPResponseSerializer()
        return manager
    }()
    
    func push(to:User, type:GamePush, game:[String:String], error: @escaping(NSError?) -> ()) {
        if to.token != nil {
            let ref = FIRDatabase.database().reference()
            var text:String = ""
            if type == .invite {
                let colorText = (game["white"]! == currentUser()!.uid!) ? "black" : "white"
                text = "\(currentUser()!.name!) invite you play against him with \(colorText) figures."
                ref.child("games").child(game["uid"]!).setValue(game)
            } else if type == .accept {
                text = "\(currentUser()!.name!) accepted your invite."
            } else if type == .reject {
                text = "\(currentUser()!.name!) rejected your invite."
                ref.child("games").child(game["uid"]!).removeValue()
            } else if type == .turn {
                text = "\(currentUser()!.name!) made move [\(game["turn"]!)]"
                ref.child("games").child(game["uid"]!).setValue(game)
            } else if type == .surrender {
                text = "\(currentUser()!.name!) surrendered."
                ref.child("games").child(game["uid"]!).removeValue()
            } else {
                error(vchessError("INVALID DATA FORMAT"))
            }
            let notification:[String:Any] = [
                "title" : "v-Chess",
                "sound":"default",
                "body" : text,
                "content_available": true]
            let data:[String:Int] = ["pushType" : type.rawValue]
            
            let message:[String:Any] = ["to" : to.token!, "priority" : "high", "notification" : notification, "data" : data]
            httpManager.post("send", parameters: message, progress: nil, success: { task, response in
                error(nil)
            }, failure: { task, err in
                error(err as NSError?)
            })
        } else {
            error(vchessError("USER HAVE NO TOKEN"))
        }
    }
}

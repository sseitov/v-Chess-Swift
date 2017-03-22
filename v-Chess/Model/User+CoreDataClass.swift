//
//  User+CoreDataClass.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 14.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import Foundation
import CoreData
import Firebase
import CoreData
import SDWebImage

enum SocialType:Int {
    case email = 0
    case facebook = 1
    case google = 2
}

enum AvailableStatus:Int {
    case closed = 0
    case available = 1
    case invited = 2
    case playing = 3
}

public class User: NSManagedObject {
    
    lazy var socialType: SocialType = {
        if let val = SocialType(rawValue: Int(self.accountType)) {
            return val
        } else {
            return .email
        }
    }()
    
    func socialTypeName() -> String {
        switch socialType {
        case .email:
            return "Email"
        case .facebook:
            return "Facebook"
        case .google:
            return "Google +"
        }
    }
    
    func setAvailable(_ status:AvailableStatus, onlineGame:String? = nil ) {
        availableStatus = Int16(status.rawValue)
        var data:[String:Any] = ["status": status.rawValue]
        if onlineGame != nil {
            online = onlineGame
            data["game"] = onlineGame!
        }
        Model.shared.saveContext()
        let ref = FIRDatabase.database().reference()
        ref.child("available").child(uid!).setValue(data)
    }
    
    func status() -> AvailableStatus {
        if let st = AvailableStatus(rawValue: Int(availableStatus)) {
            return st
        } else {
            return .closed
        }
    }
    
    func getData() -> [String:Any] {
        var profile:[String : Any] = ["socialType" : Int(accountType)]
        if email != nil {
            profile["email"] = email!
        }
        if name != nil {
            profile["name"] = name!
        }
        if avatarURL != nil {
            profile["avatarURL"] = avatarURL!
        }
        return profile
    }
    
    func setData(_ profile:[String : Any], completion: @escaping() -> ()) {
        if let typeVal = profile["socialType"] as? Int {
            accountType = Int16(typeVal)
        } else {
            accountType = 0
        }
        
        email = profile["email"] as? String
        name = profile["name"] as? String
        
        avatarURL = profile["avatarURL"] as? String
        
        if avatarURL != nil {
            if accountType > 0, let url = URL(string: avatarURL!) {
                SDWebImageDownloader.shared().downloadImage(with: url, options: [], progress: { _ in}, completed: { _, data, error, _ in
                    self.avatar = data as NSData?
                    Model.shared.saveContext()
                    completion()
                })
            } else {
                let ref = Model.shared.storageRef.child(avatarURL!)
                ref.data(withMaxSize: INT64_MAX, completion: { data, error in
                    self.avatar = data as NSData?
                    Model.shared.saveContext()
                    completion()
                })
            }
        } else {
            avatar = nil
            completion()
        }
    }

}

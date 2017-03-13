//
//  User+CoreDataClass.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 13.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import Foundation
import CoreData

import CoreData
import SDWebImage

enum SocialType:Int {
    case email = 0
    case facebook = 1
    case google = 2
}

public class User: NSManagedObject {
    
    lazy var socialType: SocialType = {
        
        if self.accountType != nil, let val =  SocialType(rawValue: self.accountType!.intValue) {
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
    
    func getData() -> [String:Any] {
        var profile:[String : Any] = ["socialType" : self.accountType!.intValue]
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
            self.accountType = NSNumber(integerLiteral: typeVal)
        } else {
            self.accountType = NSNumber(integerLiteral: SocialType.email.rawValue)
        }
        email = profile["email"] as? String
        name = profile["name"] as? String
        
        avatarURL = profile["avatarURL"] as? String
        
        if avatarURL != nil {
            if accountType!.intValue > 0, let url = URL(string: avatarURL!) {
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

//
//  User+CoreDataProperties.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 14.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var accountType: Int16
    @NSManaged public var available: Bool
    @NSManaged public var avatar: NSData?
    @NSManaged public var avatarURL: String?
    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var token: String?
    @NSManaged public var uid: String?

}

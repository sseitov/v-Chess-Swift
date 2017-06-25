//
//  AppUser+CoreDataProperties.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 25.06.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import Foundation
import CoreData


extension AppUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppUser> {
        return NSFetchRequest<AppUser>(entityName: "AppUser")
    }

    @NSManaged public var accountType: Int16
    @NSManaged public var avatar: NSData?
    @NSManaged public var avatarURL: String?
    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var token: String?
    @NSManaged public var uid: String?
    @NSManaged public var availableStatus: Int16

}

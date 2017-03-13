//
//  ChessGame+CoreDataProperties.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 13.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import Foundation
import CoreData


extension ChessGame {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChessGame> {
        return NSFetchRequest<ChessGame>(entityName: "ChessGame");
    }

    @NSManaged public var black: String?
    @NSManaged public var date: String?
    @NSManaged public var eco: String?
    @NSManaged public var event: String?
    @NSManaged public var package: String?
    @NSManaged public var result: String?
    @NSManaged public var round: String?
    @NSManaged public var site: String?
    @NSManaged public var turns: String?
    @NSManaged public var white: String?

}

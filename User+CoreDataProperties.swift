//
//  User+CoreDataProperties.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-05-12.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var password: String?
    @NSManaged public var aboutMe: String?

}

extension User : Identifiable {

}

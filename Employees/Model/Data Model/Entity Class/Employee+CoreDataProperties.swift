//
//  Employee+CoreDataProperties.swift
//  Employees
//
//  Created by Farzana Sultana on 7/27/19.
//

import Foundation
import CoreData


extension Employee {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Employee> {
        return NSFetchRequest<Employee>(entityName: "Employee")
    }

    @NSManaged public var iD: String?
    @NSManaged public var name: String?
    @NSManaged public var age: String?
    @NSManaged public var salary: String?
    @NSManaged public var profileImage: String?
    @NSManaged public var rating: Int32

}

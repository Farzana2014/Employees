//
//  EEmployee.swift
//  Employees
//
//  Created by Farzana Sultana on 7/27/19.
//

import UIKit

class EEmployee: NSObject {
    
   @objc var Id: String!
   @objc var rating: NSNumber!
   @objc var employee_salary: String!
   @objc var employee_name: String!
   @objc var employee_age: String!
   @objc var profile_image: String?
    
    override init() {
        super.init()
    }
  
}

//
//  Mapper.swift
//  Employees
//
//  Created by Farzana Sultana on 7/27/19.
//

import UIKit
import CoreData

class Mapper: NSObject {

    
    class  func convert(fromEntity entity:NSObject, toManaged managed:NSManagedObject){
        
        if (entity.isKind(of: EEmployee.self)){
            
            let eObj = entity as! EEmployee
            let obj = managed as! Employee
            
            obj.iD = eObj.Id
            obj.rating = Int32(eObj.rating.intValue)
            obj.name = eObj.employee_name
            obj.age =  eObj.employee_age
            obj.salary =  eObj.employee_salary
            obj.profileImage = eObj.profile_image
          
            return
        }
        
    }
    
    class  func convertToEntity(fromManaged managed:NSManagedObject)->NSObject!{
    
        if (managed.isKind(of: Employee.self)){
            
            let eObj = EEmployee()
            let obj = managed as! Employee
            
            eObj.Id = obj.iD 
            eObj.employee_name = obj.name
            eObj.employee_age = obj.age
            eObj.rating = obj.rating as NSNumber
            eObj.profile_image = obj.profileImage
            eObj.employee_salary = obj.salary
           
            return eObj
        }
        
        return nil
    }
    
    class func getEmployees(From dic:[AnyObject]!) -> [EEmployee]{

        var employees = [EEmployee]()

        if let tempData = dic {
            
            for i in 0..<tempData.count{
                
                let employee = EEmployee()
        
                objectOfDictionary(dictionary: tempData[i] as? [String : AnyObject], cClass: EEmployee.self, object: employee)
                
                let dic = tempData[i] as! [String : AnyObject]
                if let aID = dic["id"]{
                    employee.Id = aID as? String
                }
                
                employee.rating = 0
                
                employees.append(employee)
                
                let dm = DataModel()
                if !dm.insertData(Array: [employee], entityName: "Employee") {
                    print ("Not saved")
                }
                
            }

        }
        
      
        return employees
    }

    
    class func dictionaryOfObject(object : NSObject)->[String: AnyObject]! {
        
        var count:UInt32 = 0
        
        let properties = class_copyPropertyList(object_getClass(object), &count) //objc_property_t
        
        var dic  = [String: AnyObject]()
        
        for i in 0...count-1 {
            
            let property = properties?[Int(i)]
            let propertyNameC = property_getName(property!)
            let propertyName =  String(cString: propertyNameC)
            
            //print(propertyName)
            
            let value = object.value(forKey: propertyName)
            
            if value != nil {
                dic.updateValue(value as AnyObject, forKey: propertyName)
            }
            else {
                dic.updateValue(NSNull() as AnyObject, forKey: propertyName)
            }
        }
        
        free(properties)
        
        return dic
    }
    
    
    @objc class  func objectOfDictionary(dictionary : [String:AnyObject]!, cClass:NSObject.Type, object : NSObject){
        
        var count:UInt32 = 0
        guard let properties = class_copyPropertyList(cClass, &count) else { return }
        
        
        for i in 0...count-1 {
            
            let property = properties[Int(i)]
            let propertyNameC = property_getName(property)
            let propertyName =  String(cString: propertyNameC)
            
            
            if let dic = dictionary {
                
                let value = dic[propertyName]
                
                
                
                if value != nil && !((value?.isEqual(NSNull()))!) {
                    object.setValue(value, forKey: propertyName)
                }
                else {
                    //object.setValue("", forKey: propertyName)
                    continue
                }
            }
            else {
                //object.setValue("", forKey: propertyName)
                continue
                
            }
            
            
        }
        
        free(properties)
        
    }
}

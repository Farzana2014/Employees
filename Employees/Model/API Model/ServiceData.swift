

import UIKit

class ServiceData: NSObject {

    // Local
    var appError: String = "Something went wrong. Please try again later."
    var apiResponsed : Bool = false
    var timedOut : Bool = false

    // Server
    var isSuccess : Bool = false
    var message: String = ""
    var messageDetail: String = ""
    var errors = [String: String]()

    var data: AnyObject!

    
    func setValueForm(Dictionary dic: [String: AnyObject]){
        
        
        if let sc = dic["StatusCode"] {
            isSuccess = (sc as! Int == 0) ? true : false
        }
        
        if  dic["Message"] is String{
            message =  dic["Message"] as! String
        }
        
        if  dic["MessageDetail"] is String{
            messageDetail =  dic["MessageDetail"] as! String
        }

        errors = [String: String]()
       
        var errorCount = 0

        
        if let errs = dic["Errors"]{

            if errs is String {
                errors["Error-\(errorCount+1)"] = errs as? String
            }
            else if errs is [String] {
                
                for err in errs as! [String]{
                    errors["Error-\(errorCount+1)"] = err
                    errorCount = errorCount + 1
                }

            }
            else if errs is [String: AnyObject]{

                
                for (k,v) in errs as! [String: AnyObject]{
                    
                    print("\(k) , \(v)")
                    
                    if v.isEqual(NSNull()){
                        errors[k] = ""
                    }
                    else if v is String {
                        errors[k] = v as? String
                    }
                    else if v is [String]{
                        
                        errors[k] =  v.componentsJoined(by: "\n")
                    }

                }
                
            }
  
        }
       
        if let dt = dic["Data"] as AnyObject? {
           data = dt
        }
    }

    
}

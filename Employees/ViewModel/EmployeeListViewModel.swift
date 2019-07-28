//
//  EmployeeListViewModel.swift
//  Employees
//
//  Created by Farzana Sultana on 7/27/19.
//


import UIKit

protocol EmployeeListViewModelDelegate: class {
    
    func modelDidEndGetEmployeeData(_ success:Bool, employees: [EEmployee], errors: [String: String])
    
}



class EmployeeListViewModel: NSObject, ServiceModelDelegate {
    
    var delegate:EmployeeListViewModelDelegate!
    
    let sm =  ServiceModel(PostCall: false, synchronous: false)
    
    
    override init() {
        
        super.init()
    }
    
    func getEmployeeList(){
        sm.delegate = self
        sm.getEmployeeData()
    }
    
    func ServiceModelDidFinishTask(_ serviceModel: ServiceModel, data:ServiceData!, service:Service){
        
        print("ServiceModelDidFinishTask")
        
        var errDic = [String:String]()
        
        if data.apiResponsed {
            
                
                if let dataArray = data.data {
                    
                    let employees = Mapper.getEmployees(From: dataArray as? [AnyObject])
                    
                    delegate.modelDidEndGetEmployeeData(true, employees: employees, errors: errDic)
                    return;
                    
                }
                
                delegate.modelDidEndGetEmployeeData(false, employees: [], errors: errDic)
                return;
//            }
//            else{
//                if data.errors.count > 0{
//                    data.errors.forEach { (k,v) in errDic[k] = v }
//                }
//                else if data.message.count != 0 {
//                    errDic[ErrorMeassage_K] = data.message
//                }
//                else{
//                    errDic[APIError_K] = API_ERROR
//                }
//            }
        }
        else{
            if data.timedOut == false{
                errDic[AppError_K] = data.appError
            }
        }
        
        delegate.modelDidEndGetEmployeeData(false, employees: [], errors: errDic)
    }
    
}


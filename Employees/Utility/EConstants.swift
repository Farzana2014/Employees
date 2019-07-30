//
//  ETConstants.swift
//  Employees
//
//  Created by Farzana Sultana on 7/27/19.
//

import Foundation
import UIKit

//MARK: - Constants


let ErrorMeassage_K = "ErrorMeassage"
let APIError_K = "APIError"
let AppError_K = "AppError"


let API_ERROR  = "Something went wrong. Please try again later"
let COMMON_ERROR  = "Something went wrong. Please try again later"
let API_Timeout = 30
let DATA_FETCH_LIMIT = 10


let DOMAIN_URL = "http://dummy.restapiexample.com/"
let EMPLOYEE_DATA_URL = "api/v1/employees"

let MytechniqueStoryboard = "Mytechnique"


//MARK: - Enums
enum MessageKey:String{
    
    case NoInternet
    case NoDataFound
}

enum Service{
    case UNKNOWN
    case EMPLOYEE_DATA
    
}




import UIKit


protocol ServiceModelDelegate: class {

    func ServiceModelDidFinishTask(_ serviceModel: ServiceModel, data:ServiceData!, service:Service)
}



class ServiceModel: NSObject, WebServiceDelegate {
    
    var service : Service
    let isPostCall: Bool
    let isSynchronousCall: Bool
    var timeOut: Double


    var delegate:ServiceModelDelegate!

     init(PostCall isPost:Bool, synchronous: Bool) {
        
        service = .UNKNOWN
        isPostCall = isPost
        isSynchronousCall = synchronous
        timeOut = Double(API_Timeout)
        
        super.init()
    }


    func getEmployeeData() {
        
        service = .EMPLOYEE_DATA
        
        accessAPI(PostData: nil, urlData: nil, headers: nil)
    }
    
    
    func header()->[String: String]{
        
        var dic = [String: String]()
//        dic["AuthToken"] = ""
//        
//        if let account = RTUserDefaults.getUserModel() {
//            if let cToken = account.Token, cToken.count > 0 {
//                dic["AuthToken"] = account.Token
//            }
//        }
//        
        return dic
    }

    
   
    func accessAPI(PostData postData: Data!, urlData: String!, headers:[String: String]!) -> Void {
        
        var urlString = ""
        
        switch service {
            
        case .EMPLOYEE_DATA:
            urlString = DOMAIN_URL + EMPLOYEE_DATA_URL
            
        default: break
            
        }
        
        print("URL : \(urlString)")

        if urlString.count != 0 {
           
            if let postData = postData{
                do {
                    let decoded = try JSONSerialization.jsonObject(with: postData, options: [])
                    
                    if let dictFromJSON = decoded as? [String:String] {
                        print(dictFromJSON)
                    } else if let dictFromJSON1 = decoded as? [String:Any] {
                        print(dictFromJSON1)
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
            
            
            let ws = WebService(Service: service, url: urlString, postCall:isPostCall, synchronous: isSynchronousCall)
            ws.connTimeOut = timeOut
            ws.delegate = self
            ws.httpBodyData=postData
            ws.urlData=urlData
            ws.headers = headers
            ws.callService()
        }
        else {
            delegate.ServiceModelDidFinishTask(self, data: nil, service: service)
        }
    }
    
    func webServiceDidFinishTask(_ webService: WebService, data:ServiceData, service:Service) {
    
        print("webServiceDidFinishTask")
        
        
            if isSynchronousCall {
                DispatchQueue.main.async{
                    
                    if data.timedOut{

                    }
                    
                    self.delegate.ServiceModelDidFinishTask(self, data: data, service: service)
                    
                }
            }
            else{
                delegate.ServiceModelDidFinishTask(self, data: data, service: service)
            }
    
    }
    
    func json(From data:AnyObject)->Data!{
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            print("Json ; \(jsonData)")
            return jsonData
        }
        catch {
            print(error.localizedDescription)
        }
        
        return nil
    }

}

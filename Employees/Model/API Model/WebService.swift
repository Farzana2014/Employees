
import UIKit

protocol WebServiceDelegate: class {
    func webServiceDidFinishTask(_ webService: WebService, data:ServiceData, service:Service)
}

class WebService: NSObject {
    
    let service: Service
    let urlString: String
    let isPostCall: Bool
    let isSynchronousCall: Bool

    var connTimeOut:Double
    var httpBodyData: Data!
    var urlData: String!
    var headers: [String:String]!

    var delegate:WebServiceDelegate?
  
    
    init(Service service :Service, url:String, postCall:Bool, synchronous: Bool){
        
        self.service = service
        urlString = url
        connTimeOut = 10
        isPostCall = postCall
        isSynchronousCall = synchronous
        
        super.init()
    }
    
    func callService() {
        
        let url = URL(string: self.urlString)
        let theRequest = NSMutableURLRequest(url: url!)
        theRequest.timeoutInterval = connTimeOut
        theRequest.httpMethod = isPostCall ? "POST": "GET"
        theRequest.httpBody = httpBodyData
        theRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        theRequest.addValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        theRequest.cachePolicy = .reloadIgnoringLocalCacheData

        if let headers = headers {
            
            for(key, value) in headers {
                theRequest.addValue(value, forHTTPHeaderField: key)
            }
            
            print("Header: \(headers)")

        }
        
        let session = URLSession.shared

        
        if  isSynchronousCall {
            
            var res : AnyObject?
            var serviceData : Data?
            var _error : NSError?

            let semaphore = DispatchSemaphore(value: 0)
            
            let task = session.dataTask(with: theRequest as URLRequest) { data, response, error in
                
                res = response
                serviceData = data
                _error = error as NSError?
                semaphore.signal()
            }
            
            task.resume()
            
            _ = semaphore.wait(timeout: .distantFuture)
            
            if let response = res, let data = serviceData {
                
                self.procesAPIResponse(response: response, returnData: data)
            }
            else{
                let serviceData = ServiceData()
                
                if let err = _error{
                    if err.code == NSURLErrorTimedOut {
                        print("timeout")
                        serviceData.timedOut = true
                    }
                }
                
                self.delegate?.webServiceDidFinishTask(self, data: serviceData, service: self.service)
            }
            
        }
        else {
            
            let task = session.dataTask(with: theRequest as URLRequest) { data, response, error in

                if let _ = response, let _ = data {
                    self.procesAPIResponse(response: response!, returnData: data)
                }
                else{
                    
                    let serviceData = ServiceData()
                    
                    if let err = error as NSError?{
                        if err.code == NSURLErrorTimedOut {
                            print("timeout")
                            serviceData.timedOut = true
                        }
                    }

                    
                    self.delegate?.webServiceDidFinishTask(self, data: serviceData, service: self.service)

                }
                
            }
            
            task.resume()
        }
        
    }
    

    func procesAPIResponse(response : AnyObject, returnData: Data!) {
        
        let serviceData = ServiceData ()
        
        if response.isKind(of: HTTPURLResponse.self) {
            
            let statusCode = response.statusCode!
            
            if !(statusCode >= 200 && statusCode < 300) {
                
                print("Connection failed with status \(statusCode)")
                
                serviceData.apiResponsed = false
                serviceData.appError = "Connection failed with status \(statusCode)"
                
                if let returnData = returnData {
                    
                    do {
                        let decoded = try JSONSerialization.jsonObject(with: returnData, options: []) as AnyObject
                        
                        serviceData.apiResponsed = true
                        serviceData.appError = ""
                        
                        if decoded is [String:AnyObject] {
                            serviceData.setValueForm(Dictionary: decoded as! [String : AnyObject])
                        }
                        else{
                            
                        }
                        
                    }
                    catch {
                        print("error getting string: \(error)")
                    }
                }
                
                delegate?.webServiceDidFinishTask(self, data: serviceData, service: service)

            }
            else{
                
                print("<Responsed>");
                serviceData.apiResponsed = true
                
                do {
                    let decoded = try JSONSerialization.jsonObject(with: returnData, options: []) as AnyObject
                    serviceData.appError = ""
                    serviceData.data = decoded
                }
                catch {
                    serviceData.appError = "Response not parsed successfully"
                }
                
                delegate?.webServiceDidFinishTask(self, data: serviceData, service: service)
                
            }
        } else {
            
            print("<Respons Error>")
            
            serviceData.apiResponsed = false
            serviceData.appError = "Response couldn't recognize."
            
            delegate?.webServiceDidFinishTask(self, data: serviceData, service: service)

        }
    
    }
    
    

}



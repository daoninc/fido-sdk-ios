// Copyright (C) 2022 Daon.
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
// DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
// TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

import Foundation

typealias ServerOperationCompletion = (Any, String) -> ()
typealias ServerOperationFailure = (ServerOperationError) -> ()

private enum ServerOperationType : String {
    case GET    = "GET"
    case POST   = "POST"
    case DELETE = "DELETE"
}

class ServerOperation: NSObject, URLSessionDataDelegate {
    // MARK:- Properties
    private var operationType : ServerOperationType
    private var url: String
    private var body : Dictionary<String, String>?
    private var completionClosure: ServerOperationCompletion
    private var failureClosure: ServerOperationFailure
    private var session: Foundation.URLSession?
    private var postDataTask: URLSessionDataTask?
    private var responseData: Data?
    private var serverUnderstoodRequest = false
    private var serverErrorCode = 0
    
    private var sessionId : String?
    
    // MARK:- Initialisation
    
    init(postUrl: String,
         resourceName: String,
         body: Dictionary<String, String>,
         session : String?,
         completion: @escaping ServerOperationCompletion,
         failure: @escaping ServerOperationFailure) {
        
        self.operationType      = .POST
        self.url                = "\(postUrl)/\(resourceName)"
        self.body               = body
        self.sessionId          = session
        self.completionClosure  = completion
        self.failureClosure     = failure
        
        super.init()
    }
    
    init(deleteUrl: String,
         resourceName: String,
         identifier: String,
         session : String?,
         completion: @escaping ServerOperationCompletion,
         failure: @escaping ServerOperationFailure) {
        
        self.operationType      = .DELETE
        self.url                = "\(deleteUrl)/\(resourceName)/\(identifier)"
        self.sessionId          = session
        self.completionClosure  = completion
        self.failureClosure     = failure
        
        super.init()
    }
    
    init(getUrl: String,
         resourceName: String,
         session : String?,
         completion: @escaping ServerOperationCompletion,
         failure: @escaping ServerOperationFailure) {
        
        self.operationType      = .GET
        self.url                = "\(getUrl)/\(resourceName)"
        self.sessionId          = session
        self.completionClosure  = completion
        self.failureClosure     = failure
        
        super.init()
    }
    
    // MARK:- Actions
    
    func start() {
        responseData    = Data()
        session         = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        let theUrl = URL(string: url)
        
        var request = URLRequest(url: theUrl!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60.0)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let host = theUrl?.host {
            request.addValue(host, forHTTPHeaderField: "Host")
        }
        
        if sessionId != nil {
            request.addValue(sessionId!, forHTTPHeaderField: "Session-Id")
        }
        
        request.httpMethod = operationType.rawValue
        
        do {
            if operationType == .POST {
                let postData = try JSONSerialization.data(withJSONObject: body!, options: JSONSerialization.WritingOptions(rawValue: 0))
                
                // DEBUG LOGGING
//                 let dataString : String = String(data: postData, encoding: String.Encoding.utf8)!
//
//                 print("Body: ", body!)
//                 print("JSON: \(dataString), length: \(postData.count)")
//                
                request.httpBody = postData
            }
            
            postDataTask = session!.dataTask(with: request)
            postDataTask!.resume()
            session!.finishTasksAndInvalidate()
        } catch _ {
            // Could not make request
            failureClosure(ServerOperationError.COULD_NOT_MAKE_REQUEST)
        }
    }
    
    func cancel() {
        if session != nil {
            session!.invalidateAndCancel()
            postDataTask = nil
        }
    }
    
    // MARK:- NSURLSessionDataDelegate
    
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        if response.isKind(of: HTTPURLResponse.self) {
            if let httpResponse = response as? HTTPURLResponse {
                serverUnderstoodRequest = httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
                
                if !serverUnderstoodRequest {
                    serverErrorCode = httpResponse.statusCode
                }
            }
        }
        
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        responseData!.append(data)
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let rawStringResponse = String(data: responseData!, encoding: String.Encoding.utf8)
        
        if error != nil {
            failureClosure(ServerOperationError(errorCode: Int(error!._code), msg: error!.localizedDescription))
        } else {
            do {
                var parsedJSON = try JSONSerialization.jsonObject(with: responseData!, options: [])
                
                var serverError : ServerOperationError?
                
                if !serverUnderstoodRequest {
                    serverError = ServerOperationError(json: parsedJSON)
                    
                    if serverError?.code == 0 && serverErrorCode != 0 {
                        let json = parsedJSON as? [String : Any]
                        let message = json?["message"] as? String
                        
                        serverError = ServerOperationError(errorCode: serverErrorCode, msg: message ?? HTTPURLResponse.localizedString(forStatusCode: serverErrorCode))
                    }
                }
                
                if error == nil && serverError == nil {
                    // We're done
                    if operationType == .DELETE {
                        // If it was a Delete operation then no JSON will have returned and parsedJSON will be nil.
                        // So set it to an empty dictionary.
                        parsedJSON = [:]
                    }
                    
                    completionClosure(parsedJSON, rawStringResponse!)
                } else {
                    // We failed
                    cancel()
                    
                    if serverError != nil {
                        failureClosure(serverError!)
                    } else {
                        failureClosure(ServerOperationError(errorCode: Int(error!._code), msg: error!.localizedDescription))
                    }
                }
            } catch _ {
                failureClosure(ServerOperationError.COULD_NOT_PARSE)
            }
        }
    }
    
    // MARK:- JSON Parsing
    
    
    internal class func string(dictionary: Dictionary<String,Any>?, key: String) -> String {
        if let dict = dictionary {
            if let value = dict[key] as? String {
                return value
            }
        }
        
        return ""
    }
    
    internal class func date(dictionary: Dictionary<String,Any>, key: String) -> Date? {
        var date : Date?
        
        if let dateString = dictionary[key] as? String {
            date = ServerOperation.date(string: dateString)
        }
        
        return date
    }
    
    
    internal class func date(string : String) -> Date? {
        // In the date "2011-11-15T12:27:53.219-05:00", objective-c does not appear to think
        // the ':' in the timezone is valid. So for now I'm replacing this so that it works.
        // let range = NSMakeRange(dateString.characters.count - 5, 5)
        
        // let str = dateString.replacingOccurrences(of: ":", with: "", options: NSString.CompareOptions(rawValue: 0), range: range)
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        var date = dateFormatter.date(from: string)
        
        if date == nil {
            // try a format without time zone
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            date = dateFormatter.date(from: string)
            
            // If date is still nil, try another format
            if (date == nil)
            {
                // This new format is what we're getting back from the TrustX Production and STaging
                // server.  It is of the format: 2012-07-31T16:51:05.155Z
                // so if all other date checks fail, try this one as well
                dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSS'Z'"
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                date = dateFormatter.date(from: string)
            }
        }
        
        return date
    }
}

//
//  HTTP
//
//  Copyright © 2019 Daon. All rights reserved.
//

import UIKit

typealias CompletionHandler = (Error?, String?) -> (Void)

class HTTP: NSObject {
    
    // MARK:- Constants
    
    static let ServerDateFormat   = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    static let ServerIssuePattern = "<p>.*<b>.*description<\\/b>.*<u>(.*).*<\\/u>.*<\\/p>"
    static let JSONErrorMessage   = "message"
    
    
    internal enum HTTPMethod : String {
        case  post   = "POST"
        case  get    = "GET"
        case  delete = "DELETE"
    }
    
    internal struct ConnectionTimeout {
        static let connection = 30.0
        static let upload     = 300.0
    }
    
    internal struct HTTPScheme {
        static let http   = "http"
        static let https  = "https"
    }
    
    internal struct HTTPStatus {
        static let ok         = 200
        static let created    = 201
        static let noContent  = 204
    }
    
    internal struct HTTPHeader {
        static let clientType     = "ClientType"
        static let contentType    = "Content-Type"
        static let accept         = "Accept"
        static let acceptEncoding = "Accept-Encoding"
        static let authorization  = "Authorization"
    }
    
    internal struct HTTPValue {
        static let client         = "id=DemoApp; version=1.0"
        static let accept         = "*/*"
        static let acceptEncoding = "identity"
        static let contentType    = "application/json; charset=utf-8"
    }
    

    static func post(url: String, payload: [String : Any], completion: @escaping CompletionHandler) {
        
        if let json = HTTP.JSONString(object: payload) {
            
            if var request = createURLRequest(url: url, method: .post) {
                request.httpBody = json.data(using: .utf8)
                
                execute(request: request, completion: completion)
            } else {
                completion(HTTPError.cannotBuildRequest, nil)
            }
        } else {
            completion(HTTPError.createJSONError, nil)
        }
    }
    
    
    static func get(url: String, completion: @escaping CompletionHandler) {
        
        if let request = createURLRequest(url: url, method: .get) {
            execute(request: request, completion: completion)
        } else {
            completion(HTTPError.cannotBuildRequest, nil)
        }
    }

    static func delete(url: String, completion: @escaping CompletionHandler) {
        
        if let request = createURLRequest(url: url, method: .delete) {
            execute(request: request, completion: completion)
        } else {
            completion(HTTPError.cannotBuildRequest, nil)
        }
    }
   
    // MARK:- Helper Methods
    
    private static func execute(request: URLRequest, completion: @escaping CompletionHandler) {
        
        Logging.log(string: "HTTP: " + (request.url?.path)!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let responseError = error {
                
                Logging.log(string: responseError.localizedDescription)
                completion(responseError, nil)
                
            } else if let httpResponse = response as? HTTPURLResponse {
                
                Logging.log(string: "HTTP response code: " + String(httpResponse.statusCode))
                
                var responseString : String?
                
                if data != nil {
                    responseString = String(data: data!, encoding: .utf8)
                }
                
                if httpResponse.statusCode == HTTPStatus.ok || httpResponse.statusCode == HTTPStatus.created {
                    
                    completion(nil, responseString)
                    
                } else if httpResponse.statusCode == HTTPStatus.noContent {
                    
                    completion(nil, nil)
                    
                } else {
                    
                    let unexpectedResponseError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : self.getError(jsonString: responseString, httpResponseCode: httpResponse.statusCode)])
                    
                    Logging.log(string: "Server operation failed: " + unexpectedResponseError.localizedDescription)
                    completion(unexpectedResponseError, nil)
                }
            } else {
                Logging.log(error: HTTPError.requestNoResponse)
                completion(HTTPError.requestNoResponse, nil)
            }
        }.resume()
    }
    
    
    private static func createURLRequest(url: String, method: HTTPMethod) -> URLRequest? {
        
        if let absoluteUrl = URL(string: url) {
            var request = URLRequest(url: absoluteUrl,
                                     cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
                                     timeoutInterval: ConnectionTimeout.connection)
            
            request.httpMethod = method.rawValue
            
            request.setValue(HTTPValue.contentType,    forHTTPHeaderField: HTTPHeader.contentType)
            request.setValue(HTTPValue.accept,         forHTTPHeaderField: HTTPHeader.accept)
            request.setValue(HTTPValue.acceptEncoding, forHTTPHeaderField: HTTPHeader.acceptEncoding)
            request.setValue(HTTPValue.client,         forHTTPHeaderField: HTTPHeader.clientType)
            
            if absoluteUrl.absoluteString.contains(HTTPScheme.https) {
                request.setValue(getBasicAuth(), forHTTPHeaderField: HTTPHeader.authorization)
            }

            return request
        }
        
        return nil;
    }
    
    private static func getBasicAuth() -> String {
        let user        = Settings.shared.getString(key: Settings.Key.serverUsername)
        let password    = Settings.shared.getString(key: Settings.Key.serverPassword)
        let userAndPwd  = base64EncodeString(stringToEncode: user + ":" + password)
        
        return "Basic " + userAndPwd
    }
    
    
    static func JSONString(object: Any) -> String? {
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            
            if let string = String(data: jsonData, encoding: String.Encoding.utf8) {
                return string
            }
        }
        catch _ {
            Logging.log(string: "Failed to convert JSON to String.")
        }
        
        return nil
    }
    
    private static func getError(jsonString : String?, httpResponseCode: Int) -> String {
        var errorMessage = "Sorry, this an unknown error"
        
        if let json = jsonString {
            
            Logging.log(string: "JSON Error string to parse: " + json)
            
            if let jsonData = json.data(using: String.Encoding.utf8) {
                do {
                    if let initialParsedJson = try JSONSerialization.jsonObject(with: jsonData, options: []) as? Dictionary<AnyHashable, AnyHashable> {
                        if let parsedError = initialParsedJson[JSONErrorMessage] as? String {
                            errorMessage = parsedError
                        }
                    } else {
                        errorMessage = "Could not deserialize error JSON"
                    }
                } catch let error {
                    errorMessage = error.localizedDescription
                    
                    if (json.contains("<!DOCTYPE html>")) {
                        // Attempt to parse out the error reason from the html.
                        if let result = stringByMatchingRegex(string: json, pattern: ServerIssuePattern) {
                            errorMessage = result
                        }
                    }
                    
                    errorMessage = "Server response: " + String(httpResponseCode) + " - \"" + HTTPURLResponse.localizedString(forStatusCode: httpResponseCode) + "\"\n\n" + "Additional info: \"" + errorMessage + "\""
                }
            } else {
                errorMessage = "Invalid JSON data"
            }
        } else {
            errorMessage = "Server response: " + String(httpResponseCode) + " - \"" + HTTPURLResponse.localizedString(forStatusCode: httpResponseCode) + "\""
        }
        
        Logging.log(string: errorMessage)
        
        return errorMessage
    }

    
    private static func base64EncodeString(stringToEncode : String) -> String {
        let utf8str         = stringToEncode.data(using: String.Encoding.utf8)
        let base64Encoded   = utf8str?.base64EncodedString()
        
        return base64Encoded!
    }
    
    private static func stringByMatchingRegex(string: String, pattern: String) -> String? {
        var matchedString : String?
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.init(rawValue: 0))
            
            if let match = regex.firstMatch(in: string, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSRange(location: 0, length: string.count)) {
                if (match.numberOfRanges >= 2) {
                    let range = match.range(at: 1)
                    matchedString = (string as NSString).substring(with: range)
                }
            }
        } catch let error {
            Logging.log(string: "Failed to perform regex: " + error.localizedDescription)
        }
        
        return matchedString
    }
    
}

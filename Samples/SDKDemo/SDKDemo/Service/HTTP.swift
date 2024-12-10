// Copyright (C) 2022 Daon.
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
// DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
// TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

import UIKit
import DaonCryptoSDK

typealias CompletionHandler = (Error?, String?) -> (Void)

class HTTP: NSObject {
    
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
    
    class func post(url: String, username: String?, payload: [String : Any], completion: @escaping CompletionHandler) {
        
        if let json = HTTP.JSONString(object: payload) {
            
            if var request = createURLRequest(url: url, method: .post, username: username) {
                request.httpBody = json.data(using: .utf8)
                
                execute(request: request, completion: completion)
            } else {
                completion(HTTPError.cannotBuildRequest, nil)
            }
        } else {
            completion(HTTPError.createJSONError, nil)
        }
    }
    
    
    class func get(url: String, username: String?, completion: @escaping CompletionHandler) {
        
        if let request = createURLRequest(url: url, method: .get, username: username) {
            execute(request: request, completion: completion)
        } else {
            completion(HTTPError.cannotBuildRequest, nil)
        }
    }

    class func delete(url: String, username: String?, completion: @escaping CompletionHandler) {
        
        if let request = createURLRequest(url: url, method: .delete, username: username) {
            execute(request: request, completion: completion)
        } else {
            completion(HTTPError.cannotBuildRequest, nil)
        }
    }
   
    // MARK:- Helper Methods
    
    private class func execute(request: URLRequest, completion: @escaping CompletionHandler) {
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let responseError = error {
                
                completion(responseError, nil)
                
            } else if let httpResponse = response as? HTTPURLResponse {
                                
                var responseString : String?
                
                if data != nil {
                    responseString = String(data: data!, encoding: .utf8)
                }
                
                if httpResponse.statusCode == HTTPStatus.ok || httpResponse.statusCode == HTTPStatus.created {
                    
                    completion(nil, responseString)
                    
                } else if httpResponse.statusCode == HTTPStatus.noContent {
                    
                    completion(nil, nil)
                    
                } else {
                    
                    let unexpectedResponseError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : HTTP.getError(jsonString: responseString, httpResponseCode: httpResponse.statusCode)])
                    
                    completion(unexpectedResponseError, nil)
                }
            } else {
                completion(HTTPError.requestNoResponse, nil)
            }
        }.resume()
    }
    
    
    private class func createURLRequest(url: String, method: HTTPMethod, username: String?) -> URLRequest? {
        
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
                if let username = username, let password = IXAKeychain.string(forKey: username) {
                    let userAndPwd = base64EncodeString(stringToEncode: username + ":" + password)
                    let basicAuth = "Basic " + userAndPwd
                    request.setValue(basicAuth, forHTTPHeaderField: HTTPHeader.authorization)
                }
            }

            return request
        }
        
        return nil;
    }
    
    
    class func JSONString(object: Any) -> String? {
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            
            if let string = String(data: jsonData, encoding: String.Encoding.utf8) {
                return string
            }
        }
        catch _ {
            print("Failed to convert JSON to String.")
        }
        
        return nil
    }
    
    private class func getError(jsonString : String?, httpResponseCode: Int) -> String {
        var errorMessage = "Sorry, this an unknown error"
        
        if let json = jsonString {
            
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
        
        print(errorMessage)
        
        return errorMessage
    }

    
    private class func base64EncodeString(stringToEncode : String) -> String {
        let utf8str         = stringToEncode.data(using: String.Encoding.utf8)
        let base64Encoded   = utf8str?.base64EncodedString()
        
        return base64Encoded!
    }
    
    private class func stringByMatchingRegex(string: String, pattern: String) -> String? {
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
           print("Failed to perform regex: \(error.localizedDescription)")
        }
        
        return matchedString
    }
    
}

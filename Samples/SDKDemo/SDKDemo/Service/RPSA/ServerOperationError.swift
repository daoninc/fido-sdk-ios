// Copyright (C) 2022 Daon.
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
// DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
// TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

import Foundation

internal class ServerOperationError : NSError, @unchecked Sendable {
    // MARK: Pre-built errors - Client
    
    internal static let COULD_NOT_PARSE                         = ServerOperationError(errorCode:-1, msg:"Could Not Parse Response.")
    internal static let COULD_NOT_MAKE_REQUEST                  = ServerOperationError(errorCode:-2, msg:"Could Not Make Request.")
    internal static let NO_SESSION_IDENTIFIER                   = ServerOperationError(errorCode:-3, msg:"Could Not Make Request. No SessionID Provided.")
    internal static let NO_REG_REQUEST                          = ServerOperationError(errorCode:-4, msg:"No registration request returned from server.")
    internal static let NO_INTERNET_CONNECTION                  = ServerOperationError(errorCode:-5, msg:"Could not make request. Please check your Internet connection.")
    
    // MARK: Pre-built errors - Server
    
    internal static let UNEXPECTED_ERROR                        = ServerOperationError(errorCode:1, msg:"An unexpected error occurred.  Please see the log files.")
    internal static let METHOD_NOT_IMPLEMENTED                  = ServerOperationError(errorCode:2, msg:"The method has not been implemented")
    internal static let USER_NOT_FOUND                          = ServerOperationError(errorCode:10, msg:"User not found")
    internal static let INVALID_CREDENTIALS                     = ServerOperationError(errorCode:11, msg:"Invalid credentials provided - the user could not be authenticated")
    internal static let INSUFFICIENT_CREDENTIALS                = ServerOperationError(errorCode:12, msg:"The user cannot be authenticated - please supply a username and password or a FIDO authentication response")
    internal static let AUTHENTICATION_REQUEST_ID_NOT_PROVIDED  = ServerOperationError(errorCode:100, msg:"The authentication request ID must be provided")
    internal static let PASSWORD_NOT_PROVIDED                   = ServerOperationError(errorCode:101, msg:"The password must be provided");
    internal static let EMAIL_NOT_PROVIDED                      = ServerOperationError(errorCode:102, msg:"The email must be provided")
    internal static let FIRST_NAME_NOT_PROVIDED                 = ServerOperationError(errorCode:103, msg:"The first name must be provided")
    internal static let LAST_NAME_NOT_PROVIDED                  = ServerOperationError(errorCode:104, msg:"The last name must be provided")
    internal static let FIDO_AUTH_COMPLETE_USER_NOT_FOUND       = ServerOperationError(errorCode:200, msg:"The user was authenticated by FIDO but this user is not in the system")
    internal static let UNKNOWN_SESSION_IDENTIFIER              = ServerOperationError(errorCode:201, msg:"Unknown session identifier")
    internal static let EXPIRED_SESSION                         = ServerOperationError(errorCode:202, msg:"The specified session has expired")
    internal static let NON_EXISTENT_SESSION                    = ServerOperationError(errorCode:203, msg:"The specified session does not exist")
    internal static let TRANSACTION_CONTENT_NOT_PROVIDED        = ServerOperationError(errorCode:303, msg:"Transaction data must be provided")
    
    
    private let jsonCodeKey             = "code"
    private let jsonMessageKey          = "message"

    init?(json: Any) {
        var code       = 0
        var message    = "Unknown Error"
        
        if let jsonRepresentation = json as? [String : Any] {
            if let jsonCode = jsonRepresentation[jsonCodeKey] {
                code = jsonCode as! Int
            }
            
            if let jsonMessage = jsonRepresentation[jsonMessageKey] {
                message = jsonMessage as! String
            }
        }
        
        super.init(domain: "Server", code: code, userInfo: [NSLocalizedDescriptionKey : message])
    }
    
    init(errorCode : Int, msg : String) {
        super.init(domain: "Server", code: errorCode, userInfo: [NSLocalizedDescriptionKey : msg])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

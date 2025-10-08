// Copyright (C) 2022 Daon.
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
// DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
// TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

internal class VerifyAuthenticationResponse : BaseNetworkResponse {
    
    internal var fidoAuthenticationResponse : String?
    internal var fidoResponseCode : Int?
    internal var fidoResponseMsg : String?

    private let jsonFidoAuthenticationResponseKey   = "fidoAuthenticationResponse"
    private let jsonFidoResponseCodeKey             = "fidoResponseCode"
    private let jsonFidoResponseMsgKey              = "fidoResponseMsg"        
    
    override init(error: ServerOperationError?) {
        super.init(error: error)
    }
    
    override init(json: Any) {
        super.init(json: json)
        
        if let jsonRepresentation = json as? [String : Any] {
            self.fidoAuthenticationResponse = jsonRepresentation[jsonFidoAuthenticationResponseKey] as? String
            self.fidoResponseCode           = jsonRepresentation[jsonFidoResponseCodeKey] as? Int
            self.fidoResponseMsg            = jsonRepresentation[jsonFidoResponseMsgKey] as? String
            
            // Patch incorrect fido.uaf.safetynet value from RP server
            self.fidoAuthenticationResponse = self.fidoAuthenticationResponse?.replacingOccurrences(of: "null", with: "")
        }
    }
    
}

// Copyright (C) 2022 Daon.
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
// DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
// TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

internal class RequestAuthenticationResponse : BaseNetworkResponse {
    
    internal var fidoAuthenticationRequest : String?
    internal var authenticationRequestId : String?
    
    private let jsonFidoAuthenticationRequestKey  = "fidoAuthenticationRequest"
    private let jsonAuthenticationRequestIdKey    = "authenticationRequestId"
        
    override init(error: ServerOperationError?) {
        super.init(error: error)
    }
    
    override init(json: Any) {
        super.init(json: json)
        
        if let jsonRepresentation = json as? [String : Any] {
            self.fidoAuthenticationRequest    = jsonRepresentation[jsonFidoAuthenticationRequestKey] as? String
            self.authenticationRequestId      = jsonRepresentation[jsonAuthenticationRequestIdKey] as? String
        }
    }

}

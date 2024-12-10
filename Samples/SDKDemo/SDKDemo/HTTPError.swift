
//  Copyright © 2018 Daon. All rights reserved.
//

import Foundation

enum HTTPError : LocalizedError {
    case none
    case cannotBuildRequest
    case requestNoResponse
    case requestCannotDecode
    case requestInvalidResponse
    case createJSONError
    case createRegistrationChallengeServerError
    case updateRegistrationChallengeCantDecode
    case updateRegistrationChallengeCantCreate
    case updateRegistrationChallengeServerError
    case createAuthenticationRequestDecodeError
    case updateAuthenticationRequestDecodeError
    case updateAuthenticationRequestCreationError
    case updateAuthenticationRequestServerError
    case policyRequestServerError
    case usersRequestServerError
    case authenticatorsRequestServerError
    case deleteError

    
    
    var errorDescription: String? {
        var errorString : String?
        
        switch self {
            case .none                                      : errorString = "Unknown"
            case .cannotBuildRequest                        : errorString = "Cannot build request."
            case .requestNoResponse                         : errorString = "Derver operation failed: No response received."
            case .requestCannotDecode                       : errorString = "Could not decode JSON response into generic object."
            case .createJSONError                           : errorString = "Could not create JSON string for request."
            case .requestInvalidResponse                    : errorString = "Request did not return a valid response."
            case .createRegistrationChallengeServerError    : errorString = "Could not decode JSON create registration challenge response."
            case .updateRegistrationChallengeCantDecode     : errorString = "Could not decode JSON update registration challenge response."
            case .updateRegistrationChallengeCantCreate     : errorString = "Could not create JSON string for update registration challenge."
            case .updateRegistrationChallengeServerError    : errorString = "Update registration challenge server error. See console for more information."
            case .createAuthenticationRequestDecodeError    : errorString = "Could not decode JSON authentication Request response."
            case .updateAuthenticationRequestDecodeError    : errorString = "Could not decode JSON update authentication request response."
            case .updateAuthenticationRequestCreationError  : errorString = "Could not create JSON string for update authentication request."
            case .updateAuthenticationRequestServerError    : errorString = "Update authentication server error. See console for more information."
            case .policyRequestServerError                  : errorString = "Could not decode JSON policy response."
            case .usersRequestServerError                   : errorString = "Could not decode JSON user response."
            case .authenticatorsRequestServerError          : errorString = "Could not decode JSON authenticators response."
            case .deleteError                               : errorString = "DELETE server operation failed: No response received."
        }
        
        if errorString != nil {
            return NSLocalizedString(errorString!, comment: "")
        } else {
            return "Unknown"
        }
    }
}



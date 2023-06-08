//
//  APIConstants.swift
//  petopia
//  Class to store the constant values used to retrieve date from API
//  Reference: https://www.youtube.com/watch?v=uaPVDTBbS7Y
//
//  Created by Winnie Ooi on 14/5/2023.
//

import Foundation

class APIConstants {
    // Client ID and Client Secret are provided by the API after a user account is created
    static let clientId = "PVoH6xz0C6dFkEOU44uPQzpZqlN77kjInqa8FNK4EFYJAfMFMe"
    static let clientSecret = "TW3VPt1Q7dXFKXyeOj9hgmtpOlxdT46HstEz0OWy"
    
    // The API host
    static let host = "api.petfinder.com"
    
    // Grant type of the API
    static let grantType = "client_credentials"
    
    // bodyParams to obtain API data
    static let bodyParams = [
        "client_id" : clientId,
        "client_secret": clientSecret,
        "grant_type": grantType
    ]
}

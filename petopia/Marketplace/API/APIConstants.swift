//
//  APIConstants.swift
//  petopia
//
//  Created by Winnie Ooi on 14/5/2023.
//

import Foundation

class APIConstants {
    static let clientId = "PVoH6xz0C6dFkEOU44uPQzpZqlN77kjInqa8FNK4EFYJAfMFMe"
    static let clientSecret = "TW3VPt1Q7dXFKXyeOj9hgmtpOlxdT46HstEz0OWy"
    static let host = "api.petfinder.com"
    static let grantType = "client_credentials"
    
    static let bodyParams = [
        "client_id" : clientId,
        "client_secret": clientSecret,
        "grant_type": grantType
    ]
}

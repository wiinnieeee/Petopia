//
//  NetworkError.swift
//  petopia
//  Class to store the error that might happen during retrieval of API data
//  Reference: https://www.youtube.com/watch?v=uaPVDTBbS7Y
//
//  Created by Winnie Ooi on 14/5/2023.
//

import Foundation

/// Network error that can happen during retrieval of API
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case generalError
}

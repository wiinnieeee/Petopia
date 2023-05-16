//
//  NetworkError.swift
//  petopia
//
//  Created by Winnie Ooi on 14/5/2023.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case generalError
}

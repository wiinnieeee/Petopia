//
//  APIService.swift
//  petopia
//  Class to call API request to fetch
//  Reference: https://www.youtube.com/watch?v=uaPVDTBbS7Y
//
//  Created by Winnie Ooi on 14/5/2023.
//

import Foundation

class APIService {
    // Static variable to be called
    static let shared = APIService()
    
    private init(){}
    
    /// Create the URL Request needed for the access token
    func createAccessTokenRequest() throws -> URLRequest {
        // Build a URL from the constants
        var components = URLComponents()
        components.scheme = "https"
        components.host = APIConstants.host
        components.path = "/v2/oauth2/token"
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        // URL Request variable created from the URL constructed
        var urlRequest = URLRequest(url: url)
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: APIConstants.bodyParams)
        
        return urlRequest
    }
    
    /// Create the access token required to query from the API
    func getAccessToken() async throws -> Token {
        let urlRequest = try createAccessTokenRequest()
        
        // Obtain data and httpResponse from the URL Request
        let (data, httpResponse) = try await URLSession.shared.data(for: urlRequest)
        
        // Check if the response is valid
        guard let httpResponse = httpResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        // Decode the data obtained to obtain the token
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let results = try decoder.decode(Token.self, from: data)
        
        return results
    }
    
    /// Query for the data from the API using the token and the query string which is the type of the animal to be queried
    func search(token: String, query: String) async throws -> [Animal] {
        // Query for 100 results per page and the type of animal
        guard let url = URL(string: "https://api.petfinder.com/v2/animals?type=\(query)&&limit=100") else {
            throw NetworkError.invalidURL
        }
        
        // Create a URL Request to request from the API
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Obtain data from the URL Request
        let (data, httpResponse) = try await URLSession.shared.data(for: urlRequest)
        
        // Check if the response is valid
        guard let httpResponse = httpResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        // Decode the data obtained from the request
        // Which is an array of animal data
        let decoder = JSONDecoder()
        let results = try decoder.decode(Response.self, from: data)
        
        // Return the results once queried
        return results.animals
    }
}

// Token to be used to query from the API
// Needs to be generated using the constants
struct Token: Codable {
    let tokenType: String
    let expiresIn: Int
    let accessToken: String
}


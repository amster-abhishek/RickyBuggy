//
//  NetworkManagerProtocol.swift
//  RickyBuggy
//

import Foundation
import Combine

// HTTP Method
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// Request Configuration
struct NetworkRequest {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let body: Data?
    let timeout: TimeInterval
    
    init(path: String, 
         method: HTTPMethod = .GET, 
         headers: [String: String]? = nil, 
         body: Data? = nil, 
         timeout: TimeInterval = 30.0) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
        self.timeout = timeout
    }
}

// Convenience Extensions
extension NetworkRequest {
    // Create a GET request
    static func get(path: String, headers: [String: String]? = nil, timeout: TimeInterval = 30.0) -> NetworkRequest {
        return NetworkRequest(path: path, method: .GET, headers: headers, timeout: timeout)
    }
    
    // Create a POST request with JSON body
    static func post(path: String, jsonBody: Data, headers: [String: String]? = nil, timeout: TimeInterval = 30.0) -> NetworkRequest {
        var requestHeaders = headers ?? [:]
        requestHeaders["Content-Type"] = "application/json"
        return NetworkRequest(path: path, method: .POST, headers: requestHeaders, body: jsonBody, timeout: timeout)
    }
    
    // Create a PUT request with JSON body
    static func put(path: String, jsonBody: Data, headers: [String: String]? = nil, timeout: TimeInterval = 30.0) -> NetworkRequest {
        var requestHeaders = headers ?? [:]
        requestHeaders["Content-Type"] = "application/json"
        return NetworkRequest(path: path, method: .PUT, headers: requestHeaders, body: jsonBody, timeout: timeout)
    }
    
    // Create a DELETE request
    static func delete(path: String, headers: [String: String]? = nil, timeout: TimeInterval = 30.0) -> NetworkRequest {
        return NetworkRequest(path: path, method: .DELETE, headers: headers, timeout: timeout)
    }
    
    // Create a PATCH request with JSON body
    static func patch(path: String, jsonBody: Data, headers: [String: String]? = nil, timeout: TimeInterval = 30.0) -> NetworkRequest {
        var requestHeaders = headers ?? [:]
        requestHeaders["Content-Type"] = "application/json"
        return NetworkRequest(path: path, method: .PATCH, headers: requestHeaders, body: jsonBody, timeout: timeout)
    }
}

protocol NetworkManagerProtocol {    
    func publisher(request: NetworkRequest) -> Publishers.MapKeyPath<Publishers.MapError<URLSession.DataTaskPublisher, Error>, Data>
    func publisher(fromFullURL url: URL) -> Publishers.MapKeyPath<Publishers.MapError<URLSession.DataTaskPublisher, Error>, Data>
}

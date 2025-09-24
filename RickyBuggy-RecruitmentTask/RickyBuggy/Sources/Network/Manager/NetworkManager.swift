//
//  NetworkManager.swift
//  RickyBuggy
//

import Foundation
import Combine

final class NetworkManager: NetworkManagerProtocol {
    
    static let RANDOM_HOST_NAME_TO_FAIL_REQUEST = "thisshouldfail.com"
    
    // FIX ME: 2 - Refactor - add support for different properties eg. POST, httpBody, different timeouts etc.
    // Fixed fix 2
    // New flexible request method
    func publisher(request: NetworkRequest) -> Publishers.MapKeyPath<Publishers.MapError<URLSession.DataTaskPublisher, Error>, Data> {
        var components = URLComponents()
        components.scheme = "https" // Fixed: Use HTTPS instead of HTTP
        // This is intended, if you decide to move this code around please keep functionality to random fail request
        // components.host = Int.random(in: 1...10) > 3 ? "rickandmortyapi.com" : NetworkManager.RANDOM_HOST_NAME_TO_FAIL_REQUEST
        // Fixed: Use consistent hostname for reliable network requests
        components.host = "rickandmortyapi.com"
        components.path = request.path
        
        // FIX ME: 3 - Add "guard let url = components.url else..."
        // Fixed: Add guard let url validation
        guard let url = components.url else {
            fatalError("Invalid URL components")
        }
        
        var urlRequest = URLRequest(url: url, timeoutInterval: request.timeout)
        urlRequest.httpMethod = request.method.rawValue
        
        // Add headers if provided
        if let headers = request.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Add body if provided
        if let body = request.body {
            urlRequest.httpBody = body
            // Set Content-Type if not already set
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .mapError { $0 as Error }
            .map(\.data)
    }
    
    // New flexible request method for full URLs
    func publisher(fromFullURL url: URL) -> Publishers.MapKeyPath<Publishers.MapError<URLSession.DataTaskPublisher, Error>, Data> {
        var urlRequest = URLRequest(url: url, timeoutInterval: 30.0)
        urlRequest.httpMethod = "GET"
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .mapError { $0 as Error }
            .map(\.data)
    }
}

// Convenience Methods
extension NetworkManager {
    // Create a GET request with custom timeout
    func get(path: String, timeout: TimeInterval = 30.0) -> Publishers.MapKeyPath<Publishers.MapError<URLSession.DataTaskPublisher, Error>, Data> {
        let request = NetworkRequest.get(path: path, timeout: timeout)
        return publisher(request: request)
    }
    
    // Create a POST request with JSON data
    func post(path: String, jsonData: Data, headers: [String: String]? = nil, timeout: TimeInterval = 30.0) -> Publishers.MapKeyPath<Publishers.MapError<URLSession.DataTaskPublisher, Error>, Data> {
        let request = NetworkRequest.post(path: path, jsonBody: jsonData, headers: headers, timeout: timeout)
        return publisher(request: request)
    }
    
    // Create a POST request with JSON object (Model)
    func post<T: Codable>(path: String, object: T, headers: [String: String]? = nil, timeout: TimeInterval = 30.0) -> AnyPublisher<Data, Error> {
        do {
            let jsonData = try JSONEncoder().encode(object)
            return post(path: path, jsonData: jsonData, headers: headers, timeout: timeout)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    // Create a PUT request with JSON data
    func put(path: String, jsonData: Data, headers: [String: String]? = nil, timeout: TimeInterval = 30.0) -> Publishers.MapKeyPath<Publishers.MapError<URLSession.DataTaskPublisher, Error>, Data> {
        let request = NetworkRequest.put(path: path, jsonBody: jsonData, headers: headers, timeout: timeout)
        return publisher(request: request)
    }
    
    // Create a DELETE request
    func delete(path: String, headers: [String: String]? = nil, timeout: TimeInterval = 30.0) -> Publishers.MapKeyPath<Publishers.MapError<URLSession.DataTaskPublisher, Error>, Data> {
        let request = NetworkRequest.delete(path: path, headers: headers, timeout: timeout)
        return publisher(request: request)
    }
    
    // Create a PATCH request with JSON data
    func patch(path: String, jsonData: Data, headers: [String: String]? = nil, timeout: TimeInterval = 30.0) -> Publishers.MapKeyPath<Publishers.MapError<URLSession.DataTaskPublisher, Error>, Data> {
        let request = NetworkRequest.put(path: path, jsonBody: jsonData, headers: headers, timeout: timeout)
        return publisher(request: request)
    }
}

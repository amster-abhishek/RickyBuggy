//
//  APIError.swift
//  RickyBuggy
//

import Foundation

// FIX ME: 1 - Refactor so it accepts and displays underlaying error
// Fixed fix 1
enum APIError: Error, Hashable, Equatable {
    case imageDataRequestFailed(error: Error)
    case charactersRequestFailed(error: Error)
    case characterDetailRequestFailed(error: Error)
    case locationRequestFailed(error: Error)
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.imageDataRequestFailed, .imageDataRequestFailed),
             (.charactersRequestFailed, .charactersRequestFailed),
             (.characterDetailRequestFailed, .characterDetailRequestFailed),
             (.locationRequestFailed, .locationRequestFailed):
            return true
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .imageDataRequestFailed:
            hasher.combine("imageDataRequestFailed")
        case .charactersRequestFailed:
            hasher.combine("charactersRequestFailed")
        case .characterDetailRequestFailed:
            hasher.combine("characterDetailRequestFailed")
        case .locationRequestFailed:
            hasher.combine("locationRequestFailed")
        }
    }
}

extension APIError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .imageDataRequestFailed(let error):
            return "Could not download image: \(error.localizedDescription)"
        case .charactersRequestFailed(let error):
            return "Could not fetch characters: \(error.localizedDescription)"
        case .characterDetailRequestFailed(let error):
            return "Could not get details of character: \(error.localizedDescription)"
        case .locationRequestFailed(let error):
            return "Could not get details of location: \(error.localizedDescription)"
        }
    }
}

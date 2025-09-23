//
//  AppearanceFrequency.swift
//  RickyBuggy
//

import Foundation


/// Level selected based on number of appearances in the show, if character appeared 10 times or more - it's high, if 3 times or more - its medium, if 1 or lower - it's low
/// - High: 10+ appearances
/// - Medium: 3-9 appearances  
/// - Low: 1-2 appearances

// FIXME: 4 - Fix issue with initialisation not working accordingly to requirements written above, try improving clean code approach
enum AppearanceFrequency: Int, CaseIterable {
    case low = 1
    case medium = 3
    case high = 10
    
    init(count: Int) {
        self = Self.allCases
            .sorted(by: { $0.rawValue > $1.rawValue })
            .first { count >= $0.rawValue } ?? .low
    }
    
    var popularity: String {
        switch self {
        case .high:
            return "So popular!"
        case .medium:
            return "Kind of popular"
        case .low:
            return "Meh"
        }
    }
}

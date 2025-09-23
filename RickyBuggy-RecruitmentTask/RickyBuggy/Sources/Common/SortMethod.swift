//
//  SortMethod.swift
//  RickyBuggy
//

// FIX ME: 5 - Fix sorting, so it works - and sorts downloaded characters
// Fixed fix 5
enum SortMethod: Int, CaseIterable {
    case name = 0
    case episodesCount
       
    var description: String {
        switch self {
        case .name:
            return "Name"
        case .episodesCount:
            return "Episodes Count"
        }
    }
}

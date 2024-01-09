//
//  LocationItemResponse.swift
//  Purs.iOS
//
//  Created by Artem Mkrtchyan on 1/9/24.
//

import Foundation

struct LocationItemResponse: Codable {
    let hours: [WorkingHours]
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case hours = "hours"
        case name = "location_name"
    }
}

struct WorkingHours: Codable {
    let day: DayOfWeek
    let end: Date
    let start: Date
    
    enum CodingKeys: String, CodingKey {
        case day = "day_of_week"
        case end = "end_local_time"
        case start = "start_local_time"
    }
}

enum DayOfWeek:String,  Codable, CaseIterable {
    case SUN , MON, TUE, WED, THU, FRI, SAT
    
    var fullName: String {
        switch self {
        case .MON: "Monday"
        case .TUE: "Tuesday"
        case .WED: "Wednesday"
        case .THU: "Thursday"
        case .FRI: "Friday"
        case .SAT: "Saturday"
        case .SUN: "Sunday"
        }
    }
    
    func ordinal() -> Self.AllCases.Index {
        return Self.allCases.firstIndex(of: self)!
    }
    
    func isToday() -> Bool {
        return Calendar.current.component(.weekdayOrdinal, from: Date.now) == ordinal()
    }
}

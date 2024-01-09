//
//  Item.swift
//  Purs.iOS
//
//  Created by Artem Mkrtchyan on 1/9/24.
//

import Foundation
import SwiftData



@Model
final class LocationSchedule {
    var name: String
    var hours: Dictionary<DayOfWeek,[[Date]]>
    
    init(name: String, workingHours: Dictionary<DayOfWeek,[[Date]]>) {
        self.name = name
        self.hours = workingHours
    }
}


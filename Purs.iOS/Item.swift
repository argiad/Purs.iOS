//
//  Item.swift
//  Purs.iOS
//
//  Created by Artem Mkrtchyan on 1/9/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

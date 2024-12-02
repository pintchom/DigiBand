//
//  RecordingModel.swift
//  DigiBand
//
//  Created by Max Pintchouk on 11/30/24.
//

import Foundation
import SwiftData

@Model
class Recording {
    var actions: [RecordedAction]
    var name: String
    var createdAt: Date
    var instruments: [Int: String]

    init(actions: [RecordedAction], name: String = "Untitled", createdAt: Date = Date(), instruments: [Int : String]) {
        self.actions = actions
        self.name = name
        self.createdAt = createdAt
        self.instruments = instruments
    }
}

@Model
class RecordedAction {
    var timestamp: Date
    var buttonNumber: Int
    
    init(timestamp: Date, buttonNumber: Int) {
        self.timestamp = timestamp
        self.buttonNumber = buttonNumber
    }
}

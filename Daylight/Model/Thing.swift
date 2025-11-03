//
//  Thing.swift
//  Daylight
//
//  Created by Sixin on 24/10/25.
//

import Foundation
import SwiftData

@Model
class Thing: Identifiable {
    var id: String = UUID().uuidString
    var title: String = ""
    var lastUpdated: Date = Date()
    var isHidden: Bool = false
    
    init(title: String) {
        self.title = title
    }
}

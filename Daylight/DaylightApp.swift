//
//  DaylightApp.swift
//  Daylight
//
//  Created by Sixin on 24/10/25.
//

import SwiftUI
import SwiftData

@main
struct DaylightApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .modelContainer(for: [Day.self, Thing.self])
        }
    }
}

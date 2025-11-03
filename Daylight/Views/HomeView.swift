//
//  HomeView.swift
//  Daylight
//
//  Created by Sixin on 24/10/25.
//

import SwiftUI

struct HomeView: View {
    @State var selectedTab: Tab = Tab.today
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
                .tag(Tab.today)
            
            ThingsView()
                .tabItem {
                    Label("Things", systemImage: "heart")
                }
                .tag(Tab.things)

            RemindersView()
                .tabItem {
                    Label("Reminders", systemImage: "bell")
                }
                .tag(Tab.reminders)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(Tab.settings)
        }
        .padding()
    }
}

enum Tab: Int {
    case today = 0
    case things = 1
    case reminders = 2
    case settings = 3
}

#Preview {
    HomeView()
}

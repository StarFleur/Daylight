//
//  TodayView.swift
//  Daylight
//
//  Created by Sixin on 26/10/25.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Binding var selectedTab: Tab
    
    @Query(filter: Day.currentDayPredicate(), sort: \.date) private var today: [Day] // Retrieve the first day
    @Query(filter: #Predicate<Thing> { $0.isHidden == false }) private var allThings: [Thing]
    
    var body: some View {
        let todayData = getToday()
        let things = todayData.things
        
        ScrollView {
            VStack(spacing: 24) {
                // Header with date
                VStack(alignment: .leading, spacing: 8) {
                    Text(Date.now, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    Text("Today")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    
                    Text("Do things that make you feel positive!")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                // Today's list
                if !things.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Completed")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(things) { thing in
                                HStack(spacing: 16) {
                                    Text(thing.title)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.green.opacity(0.2), .mint.opacity(0.2)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(.green)
                                    }
                                }
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                } else {
                    // Empty state
                    VStack(spacing: 16) {
                        Image("today")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 500)
                        
                        VStack(spacing: 16) {
                            Text("Take a moment to reflect on what you can do today. Hit the log button below to start!")
                                .font(.subheadline)
                                .padding(.horizontal, 6)
                        }
                        
                        Button {
                            // Switch to things tab
                            selectedTab = Tab.things
                        } label: {
                            Text("Log")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .transition(.opacity)
                }
                Spacer()
                
                // Progress overview
                if !things.isEmpty {
                    HStack(spacing: 16) {
                        Image("todaylogged")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 500)
                        
                        VStack(spacing: 32) {
                            let total = max(allThings.count, 1)
                            let progress = Double(things.count) / Double(total)
                            
                            Text("You've completed \(things.count) thing\(things.count > 1 ? "s": "") today!")
                                .font(.subheadline)
                                .foregroundStyle(Color("softblue"))
                            
                            ProgressView(value: progress)
                                .tint(.blue)
                                .padding(.horizontal, 2)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                }
            }
            .animation(.easeInOut, value: things.count)
        }
    }
    func getToday() -> Day {
            
        // Retrieve today from database
        if today.count > 0 {
            return today.first!
        } else {
            // If today doesn't exist, create a day and insert
            let today = Day()
            context.insert(today)
            try? context.save()
            
            return today
        }
    }
}

#Preview {
    TodayView(selectedTab: Binding.constant(Tab.today))
}

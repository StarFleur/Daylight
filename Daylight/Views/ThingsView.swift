//
//  ThingsView.swift
//  Daylight
//
//  Created by Sixin on 26/10/25.
//

import SwiftUI
import SwiftData

struct ThingsView: View {
    @Environment(\.modelContext) private var context
    
    @Query(filter: Day.currentDayPredicate(), sort: [SortDescriptor(\.date)]) private var today: [Day] // Retrieve the first day
    
    @Query(filter: #Predicate<Thing> { $0.isHidden == false }) private var things: [Thing] // If thing is not deleted, retrieve it from dataset
    
    @State private var showAddView: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with date
            VStack(alignment: .leading, spacing: 8) {
                Text(Date.now, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Text("Things")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                
                Text("Do things that make you feel happy!")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            
            if things.isEmpty {
                VStack(spacing: 32) {
                    // Display image
                    Image("things")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 500)
                        .padding(.top, 36)
                    
                    Text("Start by adding things that brighten your day. Tap the button below to get started!")
                        .font(.subheadline)
                        .padding(.horizontal, 6)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            } else {
                List {
                    ForEach(things) { thing in
                        let today = getToday()
                        
                        HStack {
                            Text(thing.title)
                            Spacer()
                            
                            Button {
                                if today.things.contains(thing) {
                                    // Remove thing from today
                                    today.things.removeAll { $0.id == thing.id }
                                    try? context.save()
                                } else {
                                    // Add thing to today
                                    today.things.append(thing)
                                    try? context.save()
                                }
                            } label: {
                                if today.things.contains(where: { $0.id == thing.id }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.blue)
                                } else {
                                    Image(systemName: "checkmark.circle")
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteThing)
                }
                .listStyle(.plain)
                .padding(.horizontal, 8)
            }
            
            Button {
                // Show sheet to add thing
                showAddView.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text(things.isEmpty ? "Add Your First Thing" : "Add New Thing")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 50)
            .padding(.vertical, 36)
        }
        .sheet(isPresented: $showAddView) {
            AddThingView()
                .presentationDetents([.fraction(0.2)])
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
    
    func deleteThing(at offsets: IndexSet) {
        for index in offsets {
            let thingToDelete = things[index]
            context.delete(thingToDelete)
        }
        try? context.save()
    }
}

#Preview {
    ThingsView()
}

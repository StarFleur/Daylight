//
//  RemindersView.swift
//  Daylight
//
//  Created by Sixin on 26/10/25.
//

import SwiftUI
import SwiftData
import UserNotifications

struct RemindersView: View {
    @AppStorage("ReminderTime") private var reminderTime: Double = Date().timeIntervalSince1970
    @AppStorage("RemindersOn") private var isRemindersOn = false
    @State private var selectedDate = Date().addingTimeInterval(86400) // 24x60x60 Add a time interval of 1 day
    @State private var isSettingsDialogShowing = false
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(Date.now, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Text("Reminders")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                
                Text("Remind yourself to do something uplifting everyday!")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Reminders")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text(isRemindersOn ? "Active" : "Inactive")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $isRemindersOn)
                        .labelsHidden()
                        .tint(Color("softblue"))
                }
                .padding(22)
                
                if isRemindersOn {
                    Divider()
                        .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color("softblue").opacity(0.15))
                                    .frame(width: 48, height: 48)
                                
                                Image(systemName: "bell.badge.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color("softblue"))
                            }
                            
                            Text("Reminder Set")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                        }
                        Text("You'll receive a reminder notification at \(formattedTime) daily.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(20)
                }
            }

            if !isRemindersOn {
                Text("Turn on reminders above to remind yourself to make each day better!")
                    .foregroundStyle(Color("softblue"))
                    .padding(.horizontal, 12)
                    .padding(.top, 16)
                
                Image("reminders")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 350)
            }
        }
        .padding(.top, 16)
        .onAppear {
            selectedDate = Date(timeIntervalSince1970: reminderTime)
        }
        .onChange(of: isRemindersOn) { oldValue, newValue in
            // Check for permissions to send notifications
            let notificationCenter = UNUserNotificationCenter.current()
            
            notificationCenter.getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .authorized:
                    print("Notifications are authorized.")
                    // Schedule notifications
                    scheduleNotifications()
                case .denied:
                    print("Notifications are denied.")
                    isRemindersOn = false
                    // Show a dialog saying that we can't send notifications and have a button to send the user to Settings
                    isSettingsDialogShowing = true
                case .notDetermined:
                    print("Notification permission has not been requested yet.")
                    // Request for permissions
                    requestNotificationPermission()
                default:
                    break
                }
            }
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            let notificationCenter = UNUserNotificationCenter.current()
            
            // Unschedule all currently scheduled notifications
            notificationCenter.removeAllPendingNotificationRequests()
            
            // Schedule new notifications
            scheduleNotifications()
            
            // Save new time
            reminderTime = selectedDate.timeIntervalSince1970
        }
        .alert(isPresented: $isSettingsDialogShowing) {
            Alert(
                title: Text("Notifications Disabled"),
                message: Text("Reminders won't be sent unless notifications are allowed. Please allow them in Settings."),
                primaryButton: .default(Text("Go to Settings"), action: {
                    // Go to Settings
                    goToSettings()
                }),
                secondaryButton: .cancel()
            )
        }
    }
        
    func goToSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
    }
        
    func requestNotificationPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted.")
                // Schedule notifications
                scheduleNotifications()
            } else {
                print("Permission denied")
                isRemindersOn = false
                // Show a dialog saying that we can't send notifications and have a button to send the user to Settings
                isSettingsDialogShowing = true
            }
            
            if let error = error {
                print("Error requesting permission: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        // Content of notifications
        let content = UNMutableNotificationContent()
        content.title = "Daylight"
        content.body = "A new day is starting! What are you up to?"
        content.sound = .default
        
        // Time components of notifications
        var dateComponents = DateComponents()
        dateComponents.hour = Calendar.autoupdatingCurrent.component(.hour, from: selectedDate)
        dateComponents.minute = Calendar.autoupdatingCurrent.component(.minute, from: selectedDate)
        
        // Create a trigger to repeat notifications every day at the selected time
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create notification request with a unique identifier UUID
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Schedule notifications
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Daily notification scheduled.")
            }
        }
    }
}

#Preview {
    RemindersView()
}

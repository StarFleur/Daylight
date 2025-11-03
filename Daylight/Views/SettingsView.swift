//
//  SettingsView.swift
//  Daylight
//
//  Created by Sixin on 26/10/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text(Date.now, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Text("Settings")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            List {
                // Rate the app
                let reviewUrl = URL(string: "link")!
                Link(destination: reviewUrl) {
                    HStack {
                        Image(systemName: "star.bubble")
                        Text("Rate the app")
                    }
                }
                
                // Recommend the app
                let shareUrl = URL(string: "link")!
                ShareLink(item: shareUrl) {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.right")
                        Text("Recommend the app")
                    }
                }
                
                // Contact (compose email)
                Button {
                    let mailUrl = createMailUrl()
                    
                    if let mailUrl = mailUrl,
                       UIApplication.shared.canOpenURL(mailUrl) {
                        UIApplication.shared.open(mailUrl)
                    } else {
                        print("Couldn't open mail client.")
                    }
                } label: {
                    HStack {
                        Image(systemName: "quote.bubble")
                        Text("Submit feedback")
                    }
                }
                
                // Privacy Policy
                let privacyUrl = URL(string: "link")!
                Link(destination: privacyUrl) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Privacy Policy")
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .tint(.primary)
        }
    }
    
    func createMailUrl() -> URL? {
        var mailUrlComponents = URLComponents()
        mailUrlComponents.scheme = "mailto"
        mailUrlComponents.path = "wusixin12@gmail.com"
        mailUrlComponents.queryItems = [
            URLQueryItem(name: "subject", value: "Feedback for Daylight app")
        ]
        return mailUrlComponents.url
    }
}

#Preview {
    SettingsView()
}

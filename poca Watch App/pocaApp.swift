//
//  pocaApp.swift
//  poca Watch App
//
//  Created by win win on 17/05/24.
//

import SwiftUI
import UserNotifications

@main
struct poca_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    checkNotificationPermission()
                }
        }
    }
    
    func checkNotificationPermission() {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .notDetermined:
                    requestNotificationPermission()
                case .denied:
                    requestNotificationPermission()
                case .authorized, .provisional, .ephemeral:
                    print("User granted notification permission")
                @unknown default:
                    print("Unknown notification permission status")
                }
            }
        }

        func requestNotificationPermission() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted {
                    print("Permission granted")
                } else if let error = error {
                    print("Permission denied: \(error.localizedDescription)")
                }
            }
        }
}

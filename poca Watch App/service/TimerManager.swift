import SwiftUI
import UserNotifications

class TimerManager: ObservableObject {
    @Published var timeString: String = "00:00"
    private var timer: Timer?
    private var endTime: Date?
    
    @Published var duration: TimeInterval = 0
    @Published var timerPhase: Int = 1
    
    @Published var remainingTime:TimeInterval = TimeInterval(30)
    @Published var orcaOffset:CGSize = CGSize(width: 0, height: 200)

    func start(duration: TimeInterval) {
        self.duration = duration
        endTime = Date().addingTimeInterval(duration)
        updateTimerString()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateTimerString()
        }
        scheduleNotification()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        timeString = formatTime(duration)
        endTime = nil
        removeNotification()
    }

    private func updateTimerString() {
        guard let endTime = endTime else { return }

        remainingTime = endTime.timeIntervalSinceNow
        
        if remainingTime <= 0 {
            timeString = "00:00"
            timerPhase = 3
            withAnimation(Animation.spring(duration: 1)) {
                orcaOffset = CGSize(width: 0, height: 26)
            }
            stop()
            // if stopped
        } else {
            timeString = formatTime(remainingTime)
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func scheduleNotification() {
        guard let endTime = endTime else { return }

        let content = UNMutableNotificationContent()
        content.title = "Timer Ended"
        content.body = "Your countdown timer has finished."
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: endTime.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: "TimerNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    private func removeNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
}

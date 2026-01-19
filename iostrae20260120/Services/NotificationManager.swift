import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleNotifications(for subscriptions: [Subscription]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let calendar = Calendar.current
        let now = Date()
        
        for sub in subscriptions {
            guard let nextDate = sub.nextDateObject else { continue }
            
            // Step 5: Schedule 6 AM notification 3 days before
            if let triggerDate = calendar.date(byAdding: .day, value: -3, to: nextDate) {
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: triggerDate)
                dateComponents.hour = 6
                dateComponents.minute = 0
                dateComponents.second = 0
                
                if let scheduledDate = calendar.date(from: dateComponents), scheduledDate > now {
                    let content = UNMutableNotificationContent()
                    content.title = "Subscription Renewal Alert"
                    content.body = "\(sub.name) is renewing on \(sub.nextdate). Price: $\(sub.price)"
                    content.sound = .default
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    let request = UNNotificationRequest(identifier: sub.id, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("Error scheduling notification: \(error)")
                        }
                    }
                }
            }
            
            // Step 6: Immediate notification on app launch if within 3 days
            let daysUntil = calendar.dateComponents([.day], from: now, to: nextDate).day ?? 100
            if daysUntil >= 0 && daysUntil <= 3 {
                let content = UNMutableNotificationContent()
                content.title = "Expiring Soon: \(sub.name)"
                content.body = "Renewing in \(daysUntil) days (\(sub.nextdate))."
                content.sound = .default
                
                // Trigger in 2 seconds
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
                let request = UNNotificationRequest(identifier: "\(sub.id)-immediate", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
}

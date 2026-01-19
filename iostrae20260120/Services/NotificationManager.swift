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
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        var immediateNotificationDelay: TimeInterval = 2
        
        for sub in subscriptions {
            guard let nextDate = sub.nextDateObject else { continue }
            let formattedDate = dateFormatter.string(from: nextDate)
            
            // Step 5: Schedule 6 AM notification for expiring items (Last 3 days)
            // We need to schedule notifications for: 
            // - 3 days before (Already implemented)
            // - 2 days before
            // - 1 day before
            // - The day of expiry
            
            // Check if we are within the 3-day window or if the window is in the future
            for offset in 0...3 {
                if let triggerDate = calendar.date(byAdding: .day, value: -offset, to: nextDate) {
                    var dateComponents = calendar.dateComponents([.year, .month, .day], from: triggerDate)
                    dateComponents.hour = 6
                    dateComponents.minute = 0
                    dateComponents.second = 0
                    
                    // Only schedule if the time is in the future
                    if let scheduledDate = calendar.date(from: dateComponents), scheduledDate > now {
                        let content = UNMutableNotificationContent()
                        content.title = "Subscription Renewal Alert"
                        content.body = "\(sub.name) is renewing on \(formattedDate) (\(offset == 0 ? "Today" : "\(offset) days left")). Price: $\(sub.price)"
                        content.sound = .default
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                        let request = UNNotificationRequest(identifier: "\(sub.id)-6am-\(offset)", content: content, trigger: trigger)
                        
                        UNUserNotificationCenter.current().add(request) { error in
                            if let error = error {
                                print("Error scheduling 6AM notification: \(error)")
                            } else {
                                print("Scheduled 6AM notification for \(sub.name) on \(dateComponents.year!)/\(dateComponents.month!)/\(dateComponents.day!)")
                            }
                        }
                    }
                }
            }
            
            // Step 6: Immediate notification on app launch if within 3 days
            let daysUntil = calendar.dateComponents([.day], from: now, to: nextDate).day ?? 100
            print("Checking subscription: \(sub.name), daysUntil: \(daysUntil)")
            
            if daysUntil >= 0 && daysUntil <= 3 {
                print("Scheduling immediate notification for \(sub.name)")
                let content = UNMutableNotificationContent()
                content.title = "Expiring Soon: \(sub.name)"
                content.body = "Renewing in \(daysUntil) days (\(formattedDate))."
                content.sound = .default
                
                // Trigger with staggered delay
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: immediateNotificationDelay, repeats: false)
                let request = UNNotificationRequest(identifier: "\(sub.id)-immediate", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error adding immediate notification: \(error)")
                    } else {
                        print("Immediate notification scheduled for \(sub.name) in \(immediateNotificationDelay) seconds")
                    }
                }
                
                immediateNotificationDelay += 2 // Stagger notifications by 2 seconds
            }
        }
    }
}

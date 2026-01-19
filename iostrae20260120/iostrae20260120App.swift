import SwiftUI
import UserNotifications
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        NotificationManager.shared.requestAuthorization()
        
        // Register Background Task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.iostrae20260120.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        return true
    }
    
    // Schedule background fetch
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.iostrae20260120.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Fetch every 15 mins (system decides actual time)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background task scheduled")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    // Handle background fetch
    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh() // Schedule next refresh
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        let operation = BlockOperation {
            let semaphore = DispatchSemaphore(value: 0)
            
            AppwriteService.shared.fetchSubscriptions { result in
                switch result {
                case .success(let documents):
                    NotificationManager.shared.scheduleNotifications(for: documents)
                    print("Background fetch completed successfully")
                case .failure(let error):
                    print("Background fetch failed: \(error)")
                }
                semaphore.signal()
            }
            
            semaphore.wait()
        }
        
        queue.addOperation(operation)
        
        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }
    }
    
    // Show notification even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

@main
struct iostrae20260120App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                appDelegate.scheduleAppRefresh()
            }
        }
    }
}

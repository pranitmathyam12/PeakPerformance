import SwiftUI
import FirebaseCore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
        
        return true
    }
}

@main
struct PeakPerformanceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Create shared instances
    @StateObject private var authManager = AuthManager()
    @StateObject private var firestoreManager = FirestoreManager()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                MainTabView()
                    .environmentObject(authManager)
                    .environmentObject(firestoreManager)
                    .environmentObject(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
                    .onAppear {
                        if let userId = authManager.user?.uid {
                            firestoreManager.fetchUserStats(userId: userId)
                            firestoreManager.fetchWorkouts(userId: userId)
                            
                            // Schedule a daily reminder at 8 AM as an example
                            let content = UNMutableNotificationContent()
                            content.title = "Daily Workout Reminder"
                            content.body = "Don't forget to complete your workout today!"
                            content.sound = .default
                            
                            var dateComponents = DateComponents()
                            dateComponents.hour = 8
                            dateComponents.minute = 0
                            
                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                            let request = UNNotificationRequest(identifier: "dailyWorkoutReminder", content: content, trigger: trigger)
                            
                            UNUserNotificationCenter.current().add(request) { error in
                                if let error = error {
                                    print("Error scheduling daily reminder: \(error.localizedDescription)")
                                } else {
                                    print("Daily reminder scheduled at 8 AM")
                                }
                            }
                        }
                    }
            } else {
                LoginView()
                    .environmentObject(authManager)
                    .environmentObject(firestoreManager)
                    .environmentObject(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
            }
        }
    }
}

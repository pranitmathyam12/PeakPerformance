import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(firestoreManager)
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Activity")
                }
                .tag(0)
            
            ActivityView()
                .environmentObject(firestoreManager)
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Fitness")
                }
                .tag(1)
            
            WorkoutListView()
                .environmentObject(firestoreManager)
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Workouts")
                }
                .tag(2)
            
            NutritionView()
                .environmentObject(firestoreManager)
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Nutrition")
                }
                .tag(3)
            
            ChatView()
                .environmentObject(firestoreManager)
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("AI Coach")
                }
                .tag(4)
            
            ProfileView()
                .environmentObject(firestoreManager)
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(5)
        }
        .accentColor(.red)
        .onAppear {
            // Ensure data is loaded when the app starts
            if let userId = authManager.user?.uid {
                firestoreManager.fetchUserStats(userId: userId)
                firestoreManager.fetchWorkouts(userId: userId)
            }
            
            // Fix for iOS 14 tab bar appearance
            UITabBar.appearance().barTintColor = UIColor.black
            UITabBar.appearance().isTranslucent = false
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(FirestoreManager())
            .environmentObject(AuthManager())
            .environmentObject(ThemeManager())
            .preferredColorScheme(.dark)
    }
}

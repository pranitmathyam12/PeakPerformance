import SwiftUI

struct HomeView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Background
                Color.black.ignoresSafeArea()
                
                // Content
                VStack(spacing: 0) {
                    // Custom header with direct implementation
                    HStack {
                        NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        .frame(width: 40, height: 40)
                        
                        Spacer()
                        
                        Text("Fitness")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        .frame(width: 40, height: 40)
                    }
                    .padding(.horizontal)
                    .padding(.top, getTopSafeAreaInset())
                    .padding(.bottom, 10)
                    .background(Color.black.opacity(0.95))
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            // Stats Grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                StatsCardView(
                                    icon: "flame.fill",
                                    value: "\(firestoreManager.userStats?.dailySteps ?? 0)",
                                    label: "Steps / Week",
                                    color: .red
                                )
                                
                                StatsCardView(
                                    icon: "bolt.fill",
                                    value: "\(firestoreManager.userStats?.caloriesBurned ?? 0)",
                                    label: "Calories / Week",
                                    color: .orange
                                )
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                            
                            // Weekly Progress Chart
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Weekly Activity")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.leading)
                                
                                ProgressChart(data: mockWeeklyData)
                                    .padding(.horizontal, 5)
                            }
                            .padding(.top, 25)
                            
                            // Additional Stats Grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                StatsCardView(
                                    icon: "figure.walk",
                                    value: String(format: "%.2f", firestoreManager.userStats?.distanceWalked ?? 0),
                                    label: "KM / Week",
                                    color: .green
                                )
                                
                                StatsCardView(
                                    icon: "drop.fill",
                                    value: "\(firestoreManager.userStats?.waterIntake ?? 0)",
                                    label: "Water (Cup)",
                                    color: .blue
                                )
                            }
                            .padding(.horizontal)
                            .padding(.top, 25)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if let userId = authManager.user?.uid {
                firestoreManager.fetchUserStats(userId: userId)
            }
        }
    }
    
    // Helper function to get safe area inset in a way that works on iOS 15+
    private func getTopSafeAreaInset() -> CGFloat {
        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            return windowScene?.windows.first?.safeAreaInsets.top ?? 0
        } else {
            return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        }
    }
}

// Define this at the file level or import from a shared model file
let mockWeeklyData: [WeeklyActivity] = [
    WeeklyActivity(day: "Mon", steps: 7500),
    WeeklyActivity(day: "Tue", steps: 8200),
    WeeklyActivity(day: "Wed", steps: 10500),
    WeeklyActivity(day: "Thu", steps: 6800),
    WeeklyActivity(day: "Fri", steps: 9300),
    WeeklyActivity(day: "Sat", steps: 5400),
    WeeklyActivity(day: "Sun", steps: 7200)
]

// Placeholder for SettingsView
struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    .frame(width: 40, height: 40)
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Spacer().frame(width: 40)
                }
                .padding(.horizontal)
                .padding(.top, getTopSafeAreaInset())
                .padding(.bottom, 10)
                .background(Color.black.opacity(0.95))
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Settings options will go here
                        SettingsRow(icon: "bell.fill", title: "Notifications", hasToggle: true)
                        SettingsRow(icon: "moon.fill", title: "Dark Mode", hasToggle: true)
                        SettingsRow(icon: "hand.raised.fill", title: "Privacy", hasToggle: false)
                        SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", hasToggle: false)
                        SettingsRow(icon: "info.circle.fill", title: "About", hasToggle: false)
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // Helper function to get safe area inset in a way that works on iOS 15+
    private func getTopSafeAreaInset() -> CGFloat {
        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            return windowScene?.windows.first?.safeAreaInsets.top ?? 0
        } else {
            return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        }
    }
}

struct SettingsRow: View {
    var icon: String
    var title: String
    var hasToggle: Bool
    @State private var isToggled = true
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.red)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
                .foregroundColor(.white)
            
            Spacer()
            
            if hasToggle {
                Toggle("", isOn: $isToggled)
                    .labelsHidden()
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}

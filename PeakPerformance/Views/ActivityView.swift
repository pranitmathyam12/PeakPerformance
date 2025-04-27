import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingStatsUpdate = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background - use theme background color
            themeManager.backgroundColor.ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                // Custom header with direct implementation
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22))
                            .foregroundColor(themeManager.textColor)
                    }
                    .frame(width: 40, height: 40)
                    
                    Spacer()
                    
                    Text("Activity")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.textColor)
                    
                    Spacer()
                    
                    Button(action: { showingStatsUpdate = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 22))
                            .foregroundColor(themeManager.textColor)
                    }
                    .frame(width: 40, height: 40)
                }
                .padding(.horizontal)
                .padding(.top, getTopSafeAreaInset())
                .padding(.bottom, 10)
                .background(themeManager.backgroundColor.opacity(0.95))
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Calorie Progress - Fixed spacing
                        ZStack {
                            // Activity ring
                            Circle()
                                .stroke(Color.red.opacity(0.2), lineWidth: 20)
                                .frame(width: 220, height: 220)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(min(Double(firestoreManager.userStats?.caloriesBurned ?? 0) / 250.0, 1.0)))
                                .stroke(Color.red, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .frame(width: 220, height: 220)
                                .rotationEffect(.degrees(-90))
                            
                            // Center text
                            VStack(spacing: 4) {
                                Text("\(firestoreManager.userStats?.caloriesBurned ?? 0)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(themeManager.textColor)
                                
                                Text("calories")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 30)
                        .padding(.bottom, 60)
                        
                        // Text below the ring with clear separation
                        VStack(spacing: 10) {
                            Text("Move")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.textColor)
                            
                            Text("\(firestoreManager.userStats?.caloriesBurned ?? 0)/250 KCAL")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        .padding(.bottom, 30)
                        
                        // Activity Stats
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("Steps")
                                    .font(.headline)
                                    .foregroundColor(themeManager.textColor)
                                
                                Spacer()
                                
                                Text("\(firestoreManager.userStats?.dailySteps ?? 0)")
                                    .font(.headline)
                                    .foregroundColor(themeManager.textColor)
                            }
                            
                            HStack {
                                Text("Distance")
                                    .font(.headline)
                                    .foregroundColor(themeManager.textColor)
                                
                                Spacer()
                                
                                Text("\(String(format: "%.2f", firestoreManager.userStats?.distanceWalked ?? 0)) KM")
                                    .font(.headline)
                                    .foregroundColor(themeManager.textColor)
                            }
                        }
                        .padding()
                        .background(themeManager.secondaryBackgroundColor)
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingStatsUpdate) {
            StatsUpdateView()
                .onDisappear {
                    // Refresh stats when sheet is dismissed
                    if let userId = authManager.user?.uid {
                        firestoreManager.fetchUserStats(userId: userId)
                        
                        // Show notification when stats are updated
                        firestoreManager.sendNotification(
                            title: "Stats Updated",
                            body: "Your activity stats have been updated successfully!"
                        )
                    }
                }
        }
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

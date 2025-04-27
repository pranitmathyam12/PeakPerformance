//
//  StatsUpdateView.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/24/25.
//

import SwiftUI

struct StatsUpdateView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var steps = ""
    @State private var calories = ""
    @State private var distance = ""
    @State private var water = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Update Your Stats")) {
                    HStack {
                        Text("Steps")
                        Spacer()
                        TextField("Steps", text: $steps)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("Calories", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Distance (km)")
                        Spacer()
                        TextField("Distance", text: $distance)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Water (cups)")
                        Spacer()
                        TextField("Water", text: $water)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Button("Update Stats") {
                    updateStats()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("Update Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Pre-fill with current values
            if let stats = firestoreManager.userStats {
                steps = "\(stats.dailySteps)"
                calories = "\(stats.caloriesBurned)"
                distance = String(format: "%.2f", stats.distanceWalked)
                water = "\(stats.waterIntake)"
            }
        }
    }
    
    private func updateStats() {
        guard let userId = authManager.user?.uid,
              var stats = firestoreManager.userStats else { return }
        
        // Update the stats object
        if let stepsValue = Int(steps) {
            stats.dailySteps = stepsValue
        }
        
        if let caloriesValue = Int(calories) {
            stats.caloriesBurned = caloriesValue
        }
        
        if let distanceValue = Double(distance) {
            stats.distanceWalked = distanceValue
        }
        
        if let waterValue = Int(water) {
            stats.waterIntake = waterValue
        }
        
        // Update in Firestore
        firestoreManager.updateUserStats(userId: userId, stats: stats)
        
        // Dismiss the view
        dismiss()
    }
}

//
//  NutritionView.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/25/25.
//

import SwiftUI

struct NutritionView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedDate = Date()
    @State private var showingAddFood = false
    @State private var selectedEntry: FoodEntry?
    @State private var showingEditFood = false
    @State private var newEntryId: String? = nil
    @State private var animateNewEntry = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom header
                    HStack {
                        Spacer()
                        
                        Text("Nutrition")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                showingAddFood = true
                            }
                        }) {
                            Image(systemName: "plus")
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
                        VStack(spacing: 20) {
                            // Date picker
                            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .padding(.horizontal)
                                .onChange(of: selectedDate) { _, newDate in
                                    if let userId = authManager.user?.uid {
                                        firestoreManager.fetchFoodEntries(userId: userId, date: newDate)
                                    }
                                }
                            
                            // Calorie summary
                            VStack(spacing: 10) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Calories Consumed")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text("\(firestoreManager.nutritionSummary.totalCalories)")
                                            .font(.title)
                                            .foregroundColor(.red)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("Remaining")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text("\(firestoreManager.nutritionSummary.remainingCalories)")
                                            .font(.title)
                                            .foregroundColor(firestoreManager.nutritionSummary.remainingCalories >= 0 ? .green : .red)
                                    }
                                }
                                
                                // Progress bar
                                let progress = min(Double(firestoreManager.nutritionSummary.totalCalories) / Double(firestoreManager.userStats?.dailyGoal.caloriesIntake ?? 2000), 1.0)
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .frame(width: geometry.size.width, height: 10)
                                            .opacity(0.3)
                                            .foregroundColor(.gray)
                                        
                                        Rectangle()
                                            .frame(width: geometry.size.width * progress, height: 10)
                                            .foregroundColor(progress > 1.0 ? .red : .green)
                                    }
                                    .cornerRadius(5)
                                }
                                .frame(height: 10)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                            .padding(.horizontal)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.easeInOut, value: firestoreManager.nutritionSummary.totalCalories)
                            
                            // Macronutrient breakdown
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Macronutrients")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                HStack(spacing: 20) {
                                    MacronutrientView(
                                        title: "Protein",
                                        value: String(format: "%.1f", firestoreManager.nutritionSummary.totalProtein),
                                        percentage: firestoreManager.nutritionSummary.proteinPercentage,
                                        color: .blue
                                    )
                                    
                                    MacronutrientView(
                                        title: "Carbs",
                                        value: String(format: "%.1f", firestoreManager.nutritionSummary.totalCarbs),
                                        percentage: firestoreManager.nutritionSummary.carbsPercentage,
                                        color: .green
                                    )
                                    
                                    MacronutrientView(
                                        title: "Fat",
                                        value: String(format: "%.1f", firestoreManager.nutritionSummary.totalFat),
                                        percentage: firestoreManager.nutritionSummary.fatPercentage,
                                        color: .orange
                                    )
                                }
                                .padding(.horizontal)
                                .transition(.scale.combined(with: .opacity))
                                .animation(.easeInOut, value: firestoreManager.nutritionSummary.totalProtein)
                                .animation(.easeInOut, value: firestoreManager.nutritionSummary.totalCarbs)
                                .animation(.easeInOut, value: firestoreManager.nutritionSummary.totalFat)
                            }
                            
                            // Food entries list
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Food Entries")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                if firestoreManager.foodEntries.isEmpty {
                                    HStack {
                                        Spacer()
                                        Text("No food entries for this day")
                                            .foregroundColor(.gray)
                                            .padding()
                                        Spacer()
                                    }
                                    .transition(.opacity)
                                } else {
                                    ForEach(firestoreManager.foodEntries) { entry in
                                        FoodEntryRow(
                                            entry: entry,
                                            onEdit: {
                                                selectedEntry = entry
                                                showingEditFood = true
                                            },
                                            isHighlighted: entry.id == newEntryId && animateNewEntry
                                        )
                                        .padding(.horizontal)
                                        .transition(.asymmetric(
                                            insertion: .scale(scale: 0.8).combined(with: .opacity).animation(.spring(response: 0.4, dampingFraction: 0.7)),
                                            removal: .scale(scale: 0.8).combined(with: .opacity).animation(.easeOut(duration: 0.25))
                                        ))
                                    }
                                }
                            }
                            .padding(.vertical)
                            .animation(.easeInOut(duration: 0.3), value: firestoreManager.foodEntries.isEmpty)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddFood) {
                FoodEntryView()
                    .onDisappear {
                        if let userId = authManager.user?.uid {
                            firestoreManager.fetchFoodEntries(userId: userId, date: selectedDate)
                            
                            // Set the new entry ID for animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.newEntryId = nil // Since we don't have the ID, just animate the latest entry
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                    self.animateNewEntry = true
                                }
                                
                                // Reset animation flag after delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    self.animateNewEntry = false
                                    self.newEntryId = nil
                                }
                            }
                        }
                    }
            }
            .sheet(isPresented: $showingEditFood) {
                if let entry = selectedEntry {
                    FoodEntryView(entry: entry)
                        .onDisappear {
                            if let userId = authManager.user?.uid {
                                firestoreManager.fetchFoodEntries(userId: userId, date: selectedDate)
                                
                                // Set the updated entry ID for animation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    self.newEntryId = entry.id
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                        self.animateNewEntry = true
                                    }
                                    
                                    // Reset animation flag after delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        self.animateNewEntry = false
                                        self.newEntryId = nil
                                    }
                                }
                            }
                        }
                }
            }
            .onAppear {
                if let userId = authManager.user?.uid {
                    firestoreManager.fetchFoodEntries(userId: userId, date: selectedDate)
                }
            }
        }
    }
    
    // Helper function to get safe area inset
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

struct MacronutrientView: View {
    let title: String
    let value: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
            
            ZStack {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 5)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: percentage / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: percentage)
                
                VStack(spacing: 0) {
                    Text(value)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("g")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            
            Text(String(format: "%.0f%%", percentage))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FoodEntryRow: View {
    let entry: FoodEntry
    let onEdit: () -> Void
    var isHighlighted: Bool = false
    
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var authManager: AuthManager
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(entry.mealType.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.calories) kcal")
                    .font(.subheadline)
                    .foregroundColor(.red)
                
                HStack(spacing: 8) {
                    Text("P: \(Int(entry.protein))g")
                        .foregroundColor(.blue)
                    
                    Text("C: \(Int(entry.carbs))g")
                        .foregroundColor(.green)
                    
                    Text("F: \(Int(entry.fat))g")
                        .foregroundColor(.orange)
                }
                .font(.caption)
            }
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
                    .padding(8)
            }
            
            Button(action: {
                showingDeleteConfirmation = true
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .padding(8)
            }
        }
        .padding()
        .background(
            ZStack {
                Color(.systemGray6)
                if isHighlighted {
                    Color.green.opacity(0.2)
                }
            }
        )
        .cornerRadius(10)
        .scaleEffect(isHighlighted ? 1.03 : 1.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isHighlighted)
        .alert("Delete Entry", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let id = entry.id, let userId = authManager.user?.uid {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        firestoreManager.deleteFoodEntry(userId: userId, entryId: id)
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this food entry?")
        }
    }
}

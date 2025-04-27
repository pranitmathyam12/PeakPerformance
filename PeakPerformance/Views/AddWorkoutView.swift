//
//  AddWorkoutView.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/25/25.
//

import SwiftUI

struct AddWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var authManager: AuthManager
    
    @State private var name = ""
    @State private var date = Date()
    @State private var duration = 30
    @State private var calories = 200
    @State private var notes = ""
    @State private var workoutType = "Strength"
    @State private var showingErrorAlert = false
    @State private var animateSave = false
    
    // Animation states
    @State private var animateFields = false
    @State private var animateSuccess = false
    
    // Callback for when workout is added
    var onWorkoutAdded: ((String?) -> Void)?
    
    let workoutTypes = ["Strength", "Cardio", "HIIT", "Yoga", "Running", "Swimming", "Cycling"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Workout Name", text: $name)
                            .foregroundColor(.white)
                            .opacity(animateFields ? 1 : 0)
                            .offset(y: animateFields ? 0 : 20)
                        
                        DatePicker("Date & Time", selection: $date)
                            .foregroundColor(.white)
                            .opacity(animateFields ? 1 : 0)
                            .offset(y: animateFields ? 0 : 20)
                        
                        Picker("Workout Type", selection: $workoutType) {
                            ForEach(workoutTypes, id: \.self) { type in
                                Text(type)
                                    .tag(type)
                            }
                        }
                        .foregroundColor(.white)
                        .opacity(animateFields ? 1 : 0)
                        .offset(y: animateFields ? 0 : 20)
                    } header: {
                        Text("Workout Details")
                            .foregroundColor(.white)
                    }
                    
                    Section {
                        Stepper("Duration: \(duration) minutes", value: $duration, in: 5...300, step: 5)
                            .foregroundColor(.white)
                            .opacity(animateFields ? 1 : 0)
                            .offset(y: animateFields ? 0 : 20)
                        
                        Stepper("Estimated Calories: \(calories)", value: $calories, in: 50...2000, step: 50)
                            .foregroundColor(.white)
                            .opacity(animateFields ? 1 : 0)
                            .offset(y: animateFields ? 0 : 20)
                    } header: {
                        Text("Statistics")
                            .foregroundColor(.white)
                    }
                    
                    Section {
                        TextEditor(text: $notes)
                            .foregroundColor(.white)
                            .frame(minHeight: 100)
                            .background(Color(.systemGray6))
                            .opacity(animateFields ? 1 : 0)
                            .offset(y: animateFields ? 0 : 20)
                    } header: {
                        Text("Notes")
                            .foregroundColor(.white)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("New Workout")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dismiss()
                            }
                        }
                        .foregroundColor(.red)
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                animateSave = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                saveWorkout()
                            }
                        }
                        .disabled(name.isEmpty || firestoreManager.isLoading)
                        .foregroundColor(.red)
                        .scaleEffect(animateSave ? 1.2 : 1.0)
                        .opacity(animateSave ? 0.7 : 1.0)
                    }
                }
                .alert("Error", isPresented: $showingErrorAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(firestoreManager.errorMessage ?? "Unknown error occurred")
                }
                
                if firestoreManager.isLoading {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        .scaleEffect(2)
                }
                
                // Success animation overlay
                if animateSuccess {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.green)
                            .scaleEffect(animateSuccess ? 1.0 : 0.5)
                            .opacity(animateSuccess ? 1.0 : 0.0)
                        
                        Text("Workout Added!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top)
                            .opacity(animateSuccess ? 1.0 : 0.0)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .onAppear {
                // Animate fields when view appears
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                    animateFields = true
                }
            }
        }
    }
    
    private func saveWorkout() {
        guard let userId = authManager.user?.uid else { return }
        
        let newWorkout = Workout(
            userId: userId,
            name: name,
            date: date,
            duration: duration,
            calories: calories,
            exercises: nil,
            notes: notes.isEmpty ? nil : notes,
            isCompleted: true
        )
        
        // Fix: Update the closure to match the expected signature
        firestoreManager.addWorkout(userId: userId, workout: newWorkout) { success in
            if success {
                // Show success animation
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    animateSuccess = true
                }
                
                // Delay dismissal to show animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onWorkoutAdded?(nil) // Pass nil since we don't have workoutId
                    dismiss()
                }
            } else {
                animateSave = false
                showingErrorAlert = true
            }
        }
    }
}

struct AddWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        AddWorkoutView()
            .environmentObject(FirestoreManager())
            .environmentObject(AuthManager())
            .preferredColorScheme(.dark)
    }
}

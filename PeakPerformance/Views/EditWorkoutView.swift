//
//  EditWorkoutView.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/24/25.
//

import SwiftUI

struct EditWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var authManager: AuthManager
    
    let workout: Workout
    
    @State private var name: String
    @State private var date: Date
    @State private var duration: Int
    @State private var calories: Int
    @State private var notes: String
    @State private var showingErrorAlert = false
    @State private var animateSave = false
    @State private var animateSuccess = false
    
    init(workout: Workout) {
        self.workout = workout
        _name = State(initialValue: workout.name)
        _date = State(initialValue: workout.date)
        _duration = State(initialValue: workout.duration)
        _calories = State(initialValue: workout.calories)
        _notes = State(initialValue: workout.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Workout Name", text: $name)
                            .foregroundColor(.white)
                        
                        DatePicker("Date & Time", selection: $date)
                            .foregroundColor(.white)
                    } header: {
                        Text("Workout Details")
                            .foregroundColor(.white)
                    }
                    
                    Section {
                        Stepper("Duration: \(duration) minutes", value: $duration, in: 5...300, step: 5)
                            .foregroundColor(.white)
                        
                        Stepper("Estimated Calories: \(calories)", value: $calories, in: 50...2000, step: 50)
                            .foregroundColor(.white)
                    } header: {
                        Text("Statistics")
                            .foregroundColor(.white)
                    }
                    
                    Section {
                        TextEditor(text: $notes)
                            .foregroundColor(.white)
                            .frame(minHeight: 100)
                            .background(Color(.systemGray6))
                    } header: {
                        Text("Notes")
                            .foregroundColor(.white)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Edit Workout")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.red)
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                animateSave = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                updateWorkout()
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
                        
                        Text("Workout Updated!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top)
                            .opacity(animateSuccess ? 1.0 : 0.0)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
    
    private func updateWorkout() {
        guard let userId = authManager.user?.uid, let workoutId = workout.id else { return }
        
        var updatedWorkout = workout
        updatedWorkout.name = name
        updatedWorkout.date = date
        updatedWorkout.duration = duration
        updatedWorkout.calories = calories
        updatedWorkout.notes = notes.isEmpty ? nil : notes
        
        firestoreManager.updateWorkout(userId: userId, workoutId: workoutId, workout: updatedWorkout) { success in
            if success {
                // Show success animation
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    animateSuccess = true
                }
                
                // Send notification on successful update
                firestoreManager.sendNotification(
                    title: "Workout Updated",
                    body: "Your \(name) workout has been updated successfully!"
                )
                
                // Delay dismissal to show animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    dismiss()
                }
            } else {
                animateSave = false
                showingErrorAlert = true
            }
        }
    }
}

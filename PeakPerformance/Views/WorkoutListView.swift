//
//  WorkoutListView.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/24/25.
//

import SwiftUI

struct WorkoutListView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var authManager: AuthManager
    @State private var showingAddWorkout = false
    @State private var showingError = false
    @State private var newWorkoutId: String? = nil
    @State private var animateNewWorkout = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom header with direct implementation
                    HStack {
                        Spacer(minLength: 40)
                        
                        Text("Workouts")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                showingAddWorkout = true
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
                    
                    // Content
                    Group {
                        if firestoreManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .red))
                                .scaleEffect(1.5)
                                .frame(maxHeight: .infinity)
                                .transition(.opacity)
                        } else if firestoreManager.workouts.isEmpty {
                            EmptyWorkoutView()
                                .transition(.opacity)
                        } else {
                            WorkoutListContent(
                                workouts: firestoreManager.workouts,
                                deleteAction: deleteWorkout,
                                newWorkoutId: $newWorkoutId,
                                animateNewWorkout: $animateNewWorkout
                            )
                            .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: firestoreManager.workouts.isEmpty)
                    .animation(.easeInOut(duration: 0.3), value: firestoreManager.isLoading)
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutView(onWorkoutAdded: { workoutId in
                    // Refresh workouts when sheet is dismissed
                    if let userId = authManager.user?.uid {
                        firestoreManager.fetchWorkouts(userId: userId)
                        
                        // Set the new workout ID for animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.newWorkoutId = workoutId
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                self.animateNewWorkout = true
                            }
                            
                            // Reset animation flag after delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                self.animateNewWorkout = false
                                self.newWorkoutId = nil
                            }
                        }
                    }
                })
            }
            .alert("Error", isPresented: $showingError, presenting: firestoreManager.errorMessage) { _ in
                Button("OK", role: .cancel) { }
            } message: { message in
                Text(message)
            }
            .onChange(of: firestoreManager.errorMessage) { _, newValue in
                showingError = newValue != nil
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .onAppear {
            if let userId = authManager.user?.uid {
                print("Fetching workouts for user: \(userId)")
                firestoreManager.fetchWorkouts(userId: userId)
            }
        }
    }
    
    private func deleteWorkout(at offsets: IndexSet) {
        guard let userId = authManager.user?.uid else { return }
        
        // Use withAnimation for smooth removal
        withAnimation(.easeInOut(duration: 0.3)) {
            offsets.forEach { index in
                if let id = firestoreManager.workouts[index].id {
                    firestoreManager.deleteWorkout(userId: userId, workoutId: id)
                    
                    // Show notification when workout is deleted
                    firestoreManager.sendNotification(
                        title: "Workout Deleted",
                        body: "Your workout has been deleted successfully."
                    )
                }
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

// MARK: - WorkoutListContent
private struct WorkoutListContent: View {
    let workouts: [Workout]
    let deleteAction: (IndexSet) -> Void
    @Binding var newWorkoutId: String?
    @Binding var animateNewWorkout: Bool
    
    var body: some View {
        List {
            ForEach(workouts) { workout in
                NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                    WorkoutRowView(workout: workout)
                        .contentShape(Rectangle())
                        .listRowBackground(Color(UIColor.systemGray6))
                        .background(
                            workout.id == newWorkoutId && animateNewWorkout ?
                            Color.red.opacity(0.3) : Color.clear
                        )
                        .scaleEffect(workout.id == newWorkoutId && animateNewWorkout ? 1.03 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateNewWorkout)
                }
                .listRowBackground(Color(UIColor.systemGray6))
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity).animation(.spring(response: 0.4, dampingFraction: 0.7)),
                    removal: .scale(scale: 0.8).combined(with: .opacity).animation(.easeOut(duration: 0.25))
                ))
            }
            .onDelete(perform: deleteAction)
        }
        .listStyle(PlainListStyle())
        .background(Color.black)
    }
}

// MARK: - EmptyWorkoutView
private struct EmptyWorkoutView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            Text("No Workouts Yet")
                .font(.title3)
                .foregroundColor(.white)
            Text("Tap the + button to add your first workout")
                .font(.subheadline)
                .foregroundColor(.gray)
                .opacity(isAnimating ? 1.0 : 0.7)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - WorkoutRowView
struct WorkoutRowView: View {
    let workout: Workout
    
    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(workout.calories) kcal")
                    .font(.subheadline)
                    .foregroundColor(.red)
                
                Text(workout.formattedDuration)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

// MARK: - WorkoutDetailView
struct WorkoutDetailView: View {
    let workout: Workout
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditWorkout = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Custom header
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
                    
                    Text(workout.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 15) {
                        Button(action: { showingEditWorkout = true }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: { showingDeleteAlert = true }) {
                            Image(systemName: "trash")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                        }
                    }
                    .frame(width: 80, height: 40)
                }
                .padding(.horizontal)
                .padding(.top, getTopSafeAreaInset())
                .padding(.bottom, 10)
                .background(Color.black.opacity(0.95))
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Workout details
                        VStack(alignment: .leading, spacing: 15) {
                            DetailRow(title: "Date", value: workout.date.formatted(date: .long, time: .shortened))
                            DetailRow(title: "Duration", value: workout.formattedDuration)
                            DetailRow(title: "Calories", value: "\(workout.calories) kcal")
                            
                            if let notes = workout.notes, !notes.isEmpty {
                                Text("Notes")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(notes)
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Delete Workout", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let id = workout.id, let userId = authManager.user?.uid {
                    firestoreManager.deleteWorkout(userId: userId, workoutId: id)
                    presentationMode.wrappedValue.dismiss()
                    
                    // Show notification when workout is deleted
                    firestoreManager.sendNotification(
                        title: "Workout Deleted",
                        body: "Your workout has been deleted successfully."
                    )
                }
            }
        } message: {
            Text("Are you sure you want to delete this workout? This action cannot be undone.")
        }
        .sheet(isPresented: $showingEditWorkout) {
            // Use EditWorkoutView directly
            EditWorkoutView(workout: workout)
                .onDisappear {
                    if let userId = authManager.user?.uid {
                        firestoreManager.fetchWorkouts(userId: userId)
                    }
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

struct DetailRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.gray)
        }
    }
}

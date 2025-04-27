//
//  AuthManager.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/24/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import UserNotifications

class AuthManager: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.user = user
                self.isAuthenticated = user != nil
                
                if user != nil {
                    // User signed in
                    self.sendNotification(
                        title: "Welcome Back!",
                        body: "You've successfully logged in to PeakPerformance, \(user?.displayName ?? "User")."
                    )
                }
            }
        }
        
        // Request notification permissions
        requestNotificationPermissions()
    }
    
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void = { _ in }) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Sign up error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                // User created successfully
                self.createUserProfile()
                self.sendNotification(
                    title: "Account Created",
                    body: "Welcome to PeakPerformance! Your account has been created successfully."
                )
                completion(true)
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void = { _ in }) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Sign in error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                // User signed in successfully
                completion(true)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            sendNotification(
                title: "Signed Out",
                body: "You have been signed out of PeakPerformance."
            )
        } catch {
            errorMessage = error.localizedDescription
            print("Sign out error: \(error.localizedDescription)")
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Bool) -> Void = { _ in }) {
        isLoading = true
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Password reset error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                // Password reset email sent successfully
                self.sendNotification(
                    title: "Password Reset",
                    body: "A password reset link has been sent to your email."
                )
                completion(true)
            }
        }
    }
    
    private func createUserProfile() {
        guard let user = user else { return }
        let db = Firestore.firestore()
        
        // Create initial user stats
        let userStats = [
            "userId": user.uid,
            "dailySteps": 0,
            "caloriesBurned": 0,
            "activeMinutes": 0,
            "distanceWalked": 0.0,
            "waterIntake": 0,
            "bio": "",
            "dailyGoal": [
                "steps": 10000,
                "calories": 500,
                "activeMinutes": 30,
                "water": 8
            ]
        ] as [String: Any]
        
        db.collection("users").document(user.uid).setData(userStats) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Error creating profile: \(error.localizedDescription)"
                    print("Error creating profile: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Notifications
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else if let error = error {
                print("Notification permissions error: \(error.localizedDescription)")
            }
        }
    }
    
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error.localizedDescription)")
            }
        }
    }
}

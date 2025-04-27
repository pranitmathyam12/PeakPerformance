//
//  Userstats.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/24/25.
//

import Foundation
import FirebaseFirestore

struct UserStats: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var dailySteps: Int = 0
    var caloriesBurned: Int = 0
    var caloriesConsumed: Int? = 0 // Added for food tracking
    var activeMinutes: Int = 0
    var distanceWalked: Double = 0 // in kilometers
    var waterIntake: Int = 0 // in cups
    var bio: String? = nil // Made optional to handle missing field in Firestore
    var photoURL: String? = nil // Added to store profile photo URL
    var dailyGoal: DailyGoal = DailyGoal()
    
    var stepsProgress: Double {
        guard dailyGoal.steps > 0 else { return 0 }
        return min(1.0, Double(dailySteps) / Double(dailyGoal.steps))
    }
    
    var caloriesProgress: Double {
        guard dailyGoal.calories > 0 else { return 0 }
        return min(1.0, Double(caloriesBurned) / Double(dailyGoal.calories))
    }
    
    var caloriesIntakeProgress: Double {
        guard dailyGoal.caloriesIntake > 0 else { return 0 }
        return min(1.0, Double(caloriesConsumed ?? 0) / Double(dailyGoal.caloriesIntake))
    }
    
    var netCalories: Int {
        (caloriesConsumed ?? 0) - caloriesBurned
    }
    
    var remainingCalories: Int {
        max(0, dailyGoal.calories - caloriesBurned)
    }
    
    var remainingCaloriesIntake: Int {
        max(0, dailyGoal.caloriesIntake - (caloriesConsumed ?? 0))
    }
    
    // Added for better debugging
    var debugDescription: String {
        return """
        UserStats:
          - userId: \(userId)
          - dailySteps: \(dailySteps)/\(dailyGoal.steps)
          - caloriesBurned: \(caloriesBurned)/\(dailyGoal.calories)
          - caloriesConsumed: \(caloriesConsumed ?? 0)/\(dailyGoal.caloriesIntake)
          - activeMinutes: \(activeMinutes)/\(dailyGoal.activeMinutes)
          - waterIntake: \(waterIntake)/\(dailyGoal.water)
        """
    }
    
    static let mock = UserStats(
        userId: "testUser",
        dailySteps: 7500,
        caloriesBurned: 450,
        caloriesConsumed: 1800,
        activeMinutes: 55,
        distanceWalked: 4.2,
        waterIntake: 6,
        bio: "Fitness enthusiast",
        photoURL: nil
    )
    
    // Custom decoder init to handle missing fields in Firestore
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        id = try container.decodeIfPresent(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        
        // Fields with defaults
        dailySteps = try container.decodeIfPresent(Int.self, forKey: .dailySteps) ?? 0
        caloriesBurned = try container.decodeIfPresent(Int.self, forKey: .caloriesBurned) ?? 0
        caloriesConsumed = try container.decodeIfPresent(Int.self, forKey: .caloriesConsumed) ?? 0
        activeMinutes = try container.decodeIfPresent(Int.self, forKey: .activeMinutes) ?? 0
        distanceWalked = try container.decodeIfPresent(Double.self, forKey: .distanceWalked) ?? 0
        waterIntake = try container.decodeIfPresent(Int.self, forKey: .waterIntake) ?? 0
        
        // Optional fields
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        
        // Handle dailyGoal
        do {
            dailyGoal = try container.decode(DailyGoal.self, forKey: .dailyGoal)
        } catch {
            // If dailyGoal fails to decode, use default values
            dailyGoal = DailyGoal()
            print("Using default DailyGoal due to decoding error: \(error)")
        }
        
        // Ensure values are valid
        validateValues()
    }
    
    // Standard initializer
    init(userId: String, dailySteps: Int = 0, caloriesBurned: Int = 0, caloriesConsumed: Int? = 0,
         activeMinutes: Int = 0, distanceWalked: Double = 0, waterIntake: Int = 0,
         bio: String? = nil, photoURL: String? = nil, dailyGoal: DailyGoal = DailyGoal()) {
        self.userId = userId
        self.dailySteps = dailySteps
        self.caloriesBurned = caloriesBurned
        self.caloriesConsumed = caloriesConsumed
        self.activeMinutes = activeMinutes
        self.distanceWalked = distanceWalked
        self.waterIntake = waterIntake
        self.bio = bio
        self.photoURL = photoURL
        self.dailyGoal = dailyGoal
        
        // Ensure values are valid
        validateValues()
    }
    
    // Ensure all values are within reasonable ranges
    private mutating func validateValues() {
        dailySteps = max(0, dailySteps)
        caloriesBurned = max(0, caloriesBurned)
        if let consumed = caloriesConsumed {
            caloriesConsumed = max(0, consumed)
        }
        activeMinutes = max(0, activeMinutes)
        distanceWalked = max(0, distanceWalked)
        waterIntake = max(0, waterIntake)
    }
    
    // Helper method to create a copy with updated daily goals
    func withUpdatedGoals(steps: Int? = nil, calories: Int? = nil,
                         caloriesIntake: Int? = nil, activeMinutes: Int? = nil,
                         water: Int? = nil) -> UserStats {
        var copy = self
        var updatedGoal = self.dailyGoal
        
        if let steps = steps {
            updatedGoal.steps = steps
        }
        
        if let calories = calories {
            updatedGoal.calories = calories
        }
        
        if let caloriesIntake = caloriesIntake {
            updatedGoal.caloriesIntake = caloriesIntake
        }
        
        if let activeMinutes = activeMinutes {
            updatedGoal.activeMinutes = activeMinutes
        }
        
        if let water = water {
            updatedGoal.water = water
        }
        
        copy.dailyGoal = updatedGoal
        return copy
    }
}

struct DailyGoal: Codable, Equatable {
    var steps: Int = 10000
    var calories: Int = 500 // Calories to burn
    var caloriesIntake: Int = 2000 // Daily calorie intake goal
    var activeMinutes: Int = 30
    var water: Int = 8 // cups
    var protein: Double = 150 // in grams
    var carbs: Double = 225 // in grams
    var fat: Double = 67 // in grams
    
    static let mock = DailyGoal()
    
    // Custom decoder init to handle missing fields in Firestore
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        steps = try container.decodeIfPresent(Int.self, forKey: .steps) ?? 10000
        calories = try container.decodeIfPresent(Int.self, forKey: .calories) ?? 500
        activeMinutes = try container.decodeIfPresent(Int.self, forKey: .activeMinutes) ?? 30
        water = try container.decodeIfPresent(Int.self, forKey: .water) ?? 8
        
        // New fields with defaults if missing
        caloriesIntake = try container.decodeIfPresent(Int.self, forKey: .caloriesIntake) ?? 2000
        protein = try container.decodeIfPresent(Double.self, forKey: .protein) ?? 150
        carbs = try container.decodeIfPresent(Double.self, forKey: .carbs) ?? 225
        fat = try container.decodeIfPresent(Double.self, forKey: .fat) ?? 67
        
        // Ensure values are valid
        validateValues()
    }
    
    // Standard initializer
    init(steps: Int = 10000, calories: Int = 500, caloriesIntake: Int = 2000,
         activeMinutes: Int = 30, water: Int = 8, protein: Double = 150,
         carbs: Double = 225, fat: Double = 67) {
        self.steps = steps
        self.calories = calories
        self.caloriesIntake = caloriesIntake
        self.activeMinutes = activeMinutes
        self.water = water
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        
        // Ensure values are valid
        validateValues()
    }
    
    // Ensure all values are within reasonable ranges
    private mutating func validateValues() {
        steps = max(1, steps)
        calories = max(1, calories)
        caloriesIntake = max(1, caloriesIntake)
        activeMinutes = max(1, activeMinutes)
        water = max(0, water)
        protein = max(0, protein)
        carbs = max(0, carbs)
        fat = max(0, fat)
    }
    
    // Debug description for better logging
    var debugDescription: String {
        return """
        DailyGoal:
          - steps: \(steps)
          - calories: \(calories)
          - caloriesIntake: \(caloriesIntake)
          - activeMinutes: \(activeMinutes)
          - water: \(water)
        """
    }
}

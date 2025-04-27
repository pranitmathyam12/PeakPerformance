//
//  NutritionModels.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/25/25.
//

import Foundation
import FirebaseFirestore

struct FoodEntry: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var name: String
    var calories: Int
    var protein: Double // in grams
    var carbs: Double // in grams
    var fat: Double // in grams
    var date: Date
    var mealType: MealType
    var servingSize: Double // in grams or ml
    var servingUnit: String // e.g., "g", "ml", "oz"
    
    enum MealType: String, Codable, CaseIterable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
    }
    
    // Computed properties for nutritional information
    var caloriesPerServing: Double {
        guard servingSize > 0 else { return 0 }
        return Double(calories) / servingSize
    }
    
    var proteinPerServing: Double {
        guard servingSize > 0 else { return 0 }
        return protein / servingSize
    }
    
    var carbsPerServing: Double {
        guard servingSize > 0 else { return 0 }
        return carbs / servingSize
    }
    
    var fatPerServing: Double {
        guard servingSize > 0 else { return 0 }
        return fat / servingSize
    }
    
    // Formatted date string
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Formatted time of day
    var timeOfDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    // Custom initializer with validation
    init(id: String? = nil, userId: String, name: String, calories: Int, protein: Double, carbs: Double, fat: Double, date: Date, mealType: MealType, servingSize: Double, servingUnit: String) {
        self.id = id
        self.userId = userId
        self.name = name
        self.calories = max(0, calories)
        self.protein = max(0, protein)
        self.carbs = max(0, carbs)
        self.fat = max(0, fat)
        self.date = date
        self.mealType = mealType
        self.servingSize = max(0.1, servingSize) // Minimum serving size of 0.1
        self.servingUnit = servingUnit.isEmpty ? "g" : servingUnit
    }
    
    // Custom decoder with validation
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        calories = max(0, try container.decode(Int.self, forKey: .calories))
        protein = max(0, try container.decode(Double.self, forKey: .protein))
        carbs = max(0, try container.decode(Double.self, forKey: .carbs))
        fat = max(0, try container.decode(Double.self, forKey: .fat))
        date = try container.decode(Date.self, forKey: .date)
        mealType = try container.decode(MealType.self, forKey: .mealType)
        servingSize = max(0.1, try container.decode(Double.self, forKey: .servingSize))
        
        let unit = try container.decode(String.self, forKey: .servingUnit)
        servingUnit = unit.isEmpty ? "g" : unit
    }
    
    // Mock data for previews
    static let mock = FoodEntry(
        userId: "testUser",
        name: "Grilled Chicken Breast",
        calories: 165,
        protein: 31,
        carbs: 0,
        fat: 3.6,
        date: Date(),
        mealType: .lunch,
        servingSize: 100,
        servingUnit: "g"
    )
}

struct NutritionSummary {
    var totalCalories: Int = 0
    var totalProtein: Double = 0
    var totalCarbs: Double = 0
    var totalFat: Double = 0
    
    var remainingCalories: Int = 0
    
    // Macronutrient percentages
    var proteinPercentage: Double {
        let proteinCalories = totalProtein * 4
        return totalCalories > 0 ? min(100, (proteinCalories / Double(totalCalories)) * 100) : 0
    }
    
    var carbsPercentage: Double {
        let carbsCalories = totalCarbs * 4
        return totalCalories > 0 ? min(100, (carbsCalories / Double(totalCalories)) * 100) : 0
    }
    
    var fatPercentage: Double {
        let fatCalories = totalFat * 9
        return totalCalories > 0 ? min(100, (fatCalories / Double(totalCalories)) * 100) : 0
    }
    
    // Macronutrient calories
    var proteinCalories: Int {
        return Int(totalProtein * 4)
    }
    
    var carbsCalories: Int {
        return Int(totalCarbs * 4)
    }
    
    var fatCalories: Int {
        return Int(totalFat * 9)
    }
    
    // Formatted values
    var formattedProtein: String {
        return String(format: "%.1f g", totalProtein)
    }
    
    var formattedCarbs: String {
        return String(format: "%.1f g", totalCarbs)
    }
    
    var formattedFat: String {
        return String(format: "%.1f g", totalFat)
    }
    
    // Initializer with validation
    init(totalCalories: Int = 0, totalProtein: Double = 0, totalCarbs: Double = 0, totalFat: Double = 0, remainingCalories: Int = 0) {
        self.totalCalories = max(0, totalCalories)
        self.totalProtein = max(0, totalProtein)
        self.totalCarbs = max(0, totalCarbs)
        self.totalFat = max(0, totalFat)
        self.remainingCalories = max(0, remainingCalories)
    }
    
    // Add a food entry to the summary
    mutating func add(entry: FoodEntry) {
        totalCalories += entry.calories
        totalProtein += entry.protein
        totalCarbs += entry.carbs
        totalFat += entry.fat
    }
    
    // Remove a food entry from the summary
    mutating func remove(entry: FoodEntry) {
        totalCalories = max(0, totalCalories - entry.calories)
        totalProtein = max(0, totalProtein - entry.protein)
        totalCarbs = max(0, totalCarbs - entry.carbs)
        totalFat = max(0, totalFat - entry.fat)
    }
    
    // Reset the summary
    mutating func reset() {
        totalCalories = 0
        totalProtein = 0
        totalCarbs = 0
        totalFat = 0
        remainingCalories = 0
    }
    
    // Update remaining calories based on daily goal
    mutating func updateRemainingCalories(dailyGoal: Int) {
        remainingCalories = max(0, dailyGoal - totalCalories)
    }
}

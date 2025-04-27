//
//  Exercise.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/24/25.
//

import Foundation
import FirebaseFirestore

struct Exercise: Identifiable, Codable, Equatable {
    var id = UUID().uuidString
    var name: String
    var category: String
    var sets: [ExerciseSet]
    
    var totalWeight: Int {
        sets.reduce(0) { $0 + ($1.weight * $1.reps) }
    }
    
    static let mock = Exercise(
        name: "Bench Press",
        category: "Chest",
        sets: [
            ExerciseSet(weight: 60, reps: 10),
            ExerciseSet(weight: 65, reps: 8)
        ]
    )
    
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.category == rhs.category &&
        lhs.sets == rhs.sets
    }
}

struct ExerciseSet: Identifiable, Codable, Equatable {
    var id = UUID().uuidString
    var weight: Int
    var reps: Int
    var isCompleted: Bool = false
    
    static let mock = ExerciseSet(weight: 60, reps: 10)
    
    static func == (lhs: ExerciseSet, rhs: ExerciseSet) -> Bool {
        lhs.id == rhs.id &&
        lhs.weight == rhs.weight &&
        lhs.reps == rhs.reps &&
        lhs.isCompleted == rhs.isCompleted
    }
}

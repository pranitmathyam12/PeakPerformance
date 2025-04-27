//
//  Workout.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/24/25.
//

import Foundation
import FirebaseFirestore

struct Workout: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var userId: String  // Required for security rules
    var name: String
    var date: Date
    var duration: Int    // in minutes
    var calories: Int
    var exercises: [Exercise]?
    var notes: String?
    var isCompleted: Bool
    @ServerTimestamp var createdAt: Date?  // Automatic timestamp
    
    var formattedDuration: String {
        let hours = duration / 60
        let minutes = duration % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
    
    // For previews and testing
    static let mock = Workout(
        userId: "testUser",
        name: "Morning Workout",
        date: Date(),
        duration: 45,
        calories: 300,
        exercises: [Exercise.mock],
        isCompleted: true
    )
    
    // Implement Equatable manually if needed for custom comparison
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        lhs.id == rhs.id &&
        lhs.userId == rhs.userId &&
        lhs.name == rhs.name &&
        lhs.date == rhs.date &&
        lhs.duration == rhs.duration &&
        lhs.calories == rhs.calories &&
        lhs.isCompleted == rhs.isCompleted
    }
}

//
//  ProgressChart.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/24/25.
//

import SwiftUI
import Charts

// Define WeeklyActivity struct in this file to resolve the "Cannot find type" error
struct WeeklyActivity: Identifiable {
    var id = UUID()
    var day: String
    var steps: Int
}

struct ProgressChart: View {
    var data: [WeeklyActivity]
    var accentColor: Color = .blue
    
    var body: some View {
        // Simplified chart implementation to fix binding issues
        Chart(data) { item in
            BarMark(
                x: .value("Day", item.day),
                y: .value("Steps", item.steps)
            )
            .foregroundStyle(accentColor.gradient)
            .cornerRadius(6)
        }
        .frame(height: 200)
        .chartYScale(domain: 0...12000)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .padding()
    }
}

struct CalorieProgressChart: View {
    var currentCalories: Double
    var goalCalories: Double
    
    private var progress: Double {
        min(currentCalories / goalCalories, 1.0)
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    Color.red.opacity(0.2),
                    lineWidth: 30
                )
            
            // Progress
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.red,
                    style: StrokeStyle(
                        lineWidth: 30,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                
            // Center content
            VStack(spacing: 8) {
                Text("\(Int(currentCalories))")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("calories")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .aspectRatio(1, contentMode: .fit)
    }
}

// Preview for testing
struct ProgressChart_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressChart(data: [
                WeeklyActivity(day: "Mon", steps: 7500),
                WeeklyActivity(day: "Tue", steps: 8200),
                WeeklyActivity(day: "Wed", steps: 10500),
                WeeklyActivity(day: "Thu", steps: 6800),
                WeeklyActivity(day: "Fri", steps: 9300),
                WeeklyActivity(day: "Sat", steps: 5400),
                WeeklyActivity(day: "Sun", steps: 7200)
            ])
            
            CalorieProgressChart(currentCalories: 175, goalCalories: 250)
                .frame(height: 250)
        }
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

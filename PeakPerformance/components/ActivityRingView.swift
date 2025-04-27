//
//  ActivityRingView.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/24/25.
//

import SwiftUI

struct ActivityRingView: View {
    var progress: Double
    var color: Color
    var thickness: CGFloat = 18
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(
                    color.opacity(0.2),
                    lineWidth: thickness
                )
            
            // Progress ring
            Circle()
                .trim(from: 0, to: min(CGFloat(progress), 1.0))
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: thickness,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            // Optional: Add text in the middle
            if let label = formattedPercentage(progress) {
                Text(label)
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundColor(color)
            }
        }
    }
    
    private func formattedPercentage(_ value: Double) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: value))
    }
}

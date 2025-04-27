//
//  SocialView.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/24/25.
//

import SwiftUI

struct SocialView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Using SimpleNavBar instead of CustomNavBar
                SimpleNavBar(
                    title: "Share Activity",
                    leftIcon: nil,
                    rightIcon: nil,
                    leftAction: nil,
                    rightAction: nil
                )
                
                // Activity rings visualization
                ZStack {
                    Circle()
                        .strokeBorder(Color.clear, lineWidth: 0)
                        .background(
                            ZStack {
                                Circle()
                                    .fill(Color.black)
                                Circle()
                                    .stroke(Color.green, lineWidth: 20)
                                    .padding(10)
                                Circle()
                                    .stroke(Color.blue, lineWidth: 20)
                                    .padding(35)
                                Circle()
                                    .stroke(Color.red, lineWidth: 20)
                                    .padding(60)
                            }
                        )
                        .frame(width: 250, height: 250)
                }
                .padding(.vertical, 20)
                
                Text("Share Activity")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Invite friends to support, challenge and cheer each other on. Share workouts, receive progress notifications and send messages - direct from the Fitness app.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Button(action: {}) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 30)
                }
                .padding(.top, 20)
            }
            .padding(.bottom, 30)
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.top)
    }
}

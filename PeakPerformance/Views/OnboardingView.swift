//
//  OnboardingView.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/24/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboarding: Bool
    
    var body: some View {
        TabView {
            OnboardingPage(
                title: "Welcome to Fitness+",
                description: "Workouts for Everyone\nEleven different types from HIIT to Yoga.",
                icon: "figure.walk",
                buttonText: "Continue",
                action: {
                    // Move to next page
                }
            )
            
            OnboardingPage(
                title: "Share Activity",
                description: "Invite friends to support, challenge and cheer each other on. Share workouts, receive progress notifications and send messages - direct from the Fitness app.",
                icon: "person.3.fill",
                buttonText: "Get Started",
                action: {
                    isOnboarding = false
                }
            )
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct OnboardingPage: View {
    var title: String
    var description: String
    var icon: String
    var buttonText: String
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(.green)
                .padding(.bottom, 30)
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 10)
            
            Spacer()
            
            Button(action: action) {
                Text(buttonText)
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                    .padding(.horizontal, 30)
            }
            .padding(.bottom, 50)
        }
    }
}



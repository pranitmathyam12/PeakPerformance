//
//  CustomNavBar.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/24/25.
//

import SwiftUI

struct SimpleNavBar: View {
    var title: String
    var leftIcon: String?
    var rightIcon: String?
    var leftAction: (() -> Void)?
    var rightAction: (() -> Void)?
    
    var body: some View {
        HStack {
            // Left icon
            if let icon = leftIcon, let action = leftAction {
                Button(action: action) {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                .frame(width: 40, height: 40)
            } else {
                Spacer()
                    .frame(width: 40, height: 40)
            }
            
            Spacer()
            
            // Title
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            // Right icon
            if let icon = rightIcon, let action = rightAction {
                Button(action: action) {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                .frame(width: 40, height: 40)
            } else {
                Spacer()
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 56)
        .background(Color.black.opacity(0.6))
    }
}

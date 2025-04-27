//
//  ThemeManager.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/25/25.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    init() {
        // Default to dark mode if no preference is saved
        self.isDarkMode = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool ?? true
    }
    
    // Helper to get the current color scheme
    var colorScheme: ColorScheme {
        return isDarkMode ? .dark : .light
    }
    
    // Helper to get background color based on current theme
    var backgroundColor: Color {
        return isDarkMode ? .black : .white
    }
    
    // Helper to get text color based on current theme
    var textColor: Color {
        return isDarkMode ? .white : .black
    }
    
    // Helper to get secondary background color
    var secondaryBackgroundColor: Color {
        return isDarkMode ? Color(UIColor.systemGray6) : Color(UIColor.systemGray5)
    }
}

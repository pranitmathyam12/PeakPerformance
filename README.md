# PeakPerformance
PeakPerformance: Your Personal Fitness Companion
Overview
PeakPerformance is a comprehensive fitness tracking application designed to help users monitor and improve their health and wellness journey. Built with SwiftUI and powered by Firebase and OpenAI integration, the app offers a seamless experience across activity tracking, personalized workout management, nutrition monitoring, and AI-powered coaching.

Features
Activity Tracking:
Monitor daily steps, calories burned, and distance walked
Track active minutes and workout progress
Visualize fitness metrics with intuitive progress rings

Workout Management:
Create and customize workout routines
Track workout history with detailed statistics
Professional animations for a polished user experience
Delete and edit existing workouts

Nutrition Tracking:
Log food entries with comprehensive nutritional information
Track macronutrient breakdown (protein, carbs, fat)
Monitor daily calorie intake and remaining calories
Visualize nutrition data with interactive charts

AI Coaching:
Receive personalized workout suggestions based on your goals
Chat with an AI fitness coach powered by OpenAI's GPT-3.5
Get answers to fitness and nutrition questions
Request workout plans based on calorie goals and time available

User Profile:
Customize personal fitness goals
Set daily targets for steps, calories, active minutes, and water intake
Schedule workout reminders with customizable notification times
Toggle between dark and light mode

Social Features:
Share your activity progress with friends
View activity rings visualization
Connect with other fitness enthusiasts

Technical Implementation:
Architecture:
Frontend: SwiftUI for building responsive user interfaces
Backend: Firebase for authentication and Firestore for real-time database
AI Integration: OpenAI API for personalized coaching
Data Storage: Local storage and cloud synchronization
Notifications: UserNotifications framework for reminders

Key Components:
FirestoreManager: Handles all database operations and data synchronization
AuthManager: Manages user authentication and session handling
ChatViewModel: Processes AI interactions and message handling

ThemeManager: Controls app appearance settings
Installation
Clone the repository

Install dependencies using CocoaPods:
text
pod install
Open the .xcworkspace file in Xcode

Configure Firebase:

Create a Firebase project:
Add your iOS app to the Firebase project
Download the GoogleService-Info.plist file and add it to your project
Enable Authentication and Firestore in the Firebase console

Configure OpenAI API:
Obtain an API key from OpenAI
Replace the API key in the ChatViewModel.swift file
Build and run the application

Requirements:
iOS 15.0+
Xcode 13.0+
Swift 5.5+
CocoaPods

Future Development
Enhanced AI capabilities through machine learning algorithms
Integration with wearable technology for real-time performance tracking
Advanced data analytics for deeper fitness insights
Expanded social features for community engagement
Specialized training programs for specific sports and activities

Acknowledgements
OpenAI for providing the GPT-3.5 API
Firebase for authentication and database services
The SwiftUI community for inspiration and resources

Contact
For questions or feedback, please contact pranitmathyam@gmail.com



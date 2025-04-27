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

Output snippits:

<img width="316" alt="Screenshot 2025-04-26 at 1 21 04 AM" src="https://github.com/user-attachments/assets/2e646108-185f-423c-9a0e-7efd9ef9d01e" />
<img width="325" alt="Screenshot 2025-04-26 at 1 20 55 AM" src="https://github.com/user-attachments/assets/87107007-9076-42d3-bc0e-c56964d69440" />
<img width="329" alt="Screenshot 2025-04-26 at 1 20 26 AM" src="https://github.com/user-attachments/assets/54cbf829-0a60-425a-a75a-95e2649b53f7" />
<img width="330" alt="Screenshot 2025-04-26 at 1 20 08 AM" src="https://github.com/user-attachments/assets/2617d40e-3206-4792-b616-26b80905ccef" />
<img width="326" alt="Screenshot 2025-04-26 at 1 19 58 AM" src="https://github.com/user-attachments/assets/4724d174-15d2-4d96-85b3-1570a4805a93" />
<img width="327" alt="Screenshot 2025-04-26 at 1 19 43 AM" src="https://github.com/user-attachments/assets/651e25e9-a25b-4238-abcb-ac7daa43cd5d" />
<img width="323" alt="Screenshot 2025-04-26 at 1 18 41 AM" src="https://github.com/user-attachments/assets/160b85fd-3e13-48d6-b6c6-87b52f725810" />
<img width="318" alt="Screenshot 2025-04-26 at 1 18 30 AM" src="https://github.com/user-attachments/assets/70295919-946f-4377-a610-14c83777c94c" />
<img width="335" alt="Screenshot 2025-04-26 at 1 17 40 AM" src="https://github.com/user-attachments/assets/4ff8ae0d-d46d-48d5-9c80-958f19971418" />
<img width="332" alt="Screenshot 2025-04-26 at 1 17 23 AM" src="https://github.com/user-attachments/assets/35142927-6ea6-46cb-be62-9f725aab4f4f" />
<img width="335" alt="Screenshot 2025-04-26 at 1 17 10 AM" src="https://github.com/user-attachments/assets/88e8e90e-31c8-4fff-9a56-a29f428ca563" />
<img width="345" alt="Screenshot 2025-04-26 at 1 16 57 AM" src="https://github.com/user-attachments/assets/6fb08afb-1a10-4c20-b049-69ebe7e01f24" />
<img width="343" alt="Screenshot 2025-04-26 at 1 16 44 AM" src="https://github.com/user-attachments/assets/2784d5af-918f-4ea8-b920-54f443e3bcef" />
<img width="345" alt="Screenshot 2025-04-26 at 1 16 32 AM" src="https://github.com/user-attachments/assets/c142e0f0-f26d-4e58-8751-fb23087bf4ea" />
<img width="341" alt="Screenshot 2025-04-26 at 1 16 10 AM" src="https://github.com/user-attachments/assets/cdf0a7e8-685a-4565-910e-6a5bbc2d6292" />




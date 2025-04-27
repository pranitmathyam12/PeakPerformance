import SwiftUI
import FirebaseStorage
import FirebaseAuth
import UserNotifications

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var firestoreManager: FirestoreManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var profileImage: Image?
    @State private var isEditingProfile = false
    @State private var isEditingGoals = false
    @State private var displayName = ""
    @State private var bio = ""
    @State private var stepsGoal = ""
    @State private var caloriesGoal = ""
    @State private var activeMinutesGoal = ""
    @State private var waterGoal = ""
    @State private var showingErrorAlert = false
    @State private var isUploading = false
    @State private var showingReminderSheet = false
    @State private var reminderTime = Date()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Custom navigation bar
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        .frame(width: 40, height: 40)
                        
                        Spacer()
                        
                        Text("Profile")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            if isEditingGoals {
                                saveGoals()
                            }
                            if isEditingProfile {
                                saveProfile()
                            }
                            isEditingProfile.toggle()
                        }) {
                            Image(systemName: isEditingProfile ? "checkmark" : "pencil")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        .frame(width: 40, height: 40)
                    }
                    .padding(.horizontal)
                    .padding(.top, getTopSafeAreaInset())
                    .padding(.bottom, 10)
                    .background(Color.black.opacity(0.95))
                    
                    // Profile Photo Section
                    VStack(spacing: 15) {
                        ZStack(alignment: .bottomTrailing) {
                            profilePhotoView
                                .frame(width: 150, height: 150)
                            
                            if isEditingProfile {
                                Button(action: { showingImagePicker = true }) {
                                    Image(systemName: "camera.fill")
                                        .padding(10)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                        .offset(x: 10, y: 10)
                                }
                            }
                        }
                        
                        Text(displayName.isEmpty ? "Your Name" : displayName)
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text(authManager.user?.email ?? "user@example.com")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical)
                    
                    // Editable Profile Fields
                    VStack(spacing: 20) {
                        if isEditingProfile {
                            TextField("Display Name", text: $displayName)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                            
                            TextField("Bio", text: $bio)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        } else {
                            if !bio.isEmpty {
                                Text(bio)
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .animation(.default, value: isEditingProfile)
                    
                    // Fitness Goals Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Fitness Goals")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { isEditingGoals.toggle() }) {
                                Image(systemName: isEditingGoals ? "checkmark" : "pencil")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }
                            .opacity(isEditingProfile ? 0 : 1)
                        }
                        .padding(.horizontal)
                        
                        if isEditingGoals && !isEditingProfile {
                            // Editable goals
                            GoalEditRow(title: "Daily Steps", value: $stepsGoal, unit: "steps")
                            GoalEditRow(title: "Daily Calories", value: $caloriesGoal, unit: "kcal")
                            GoalEditRow(title: "Active Minutes", value: $activeMinutesGoal, unit: "min")
                            GoalEditRow(title: "Water Intake", value: $waterGoal, unit: "cups")
                        } else {
                            // Display goals
                            ProfileRow(icon: "figure.walk", title: "Daily Steps Goal", value: "\(firestoreManager.userStats?.dailyGoal.steps ?? 10000)")
                            ProfileRow(icon: "flame.fill", title: "Daily Calories Goal", value: "\(firestoreManager.userStats?.dailyGoal.calories ?? 500)")
                            ProfileRow(icon: "clock.fill", title: "Active Minutes Goal", value: "\(firestoreManager.userStats?.dailyGoal.activeMinutes ?? 30)")
                            ProfileRow(icon: "drop.fill", title: "Water Intake Goal", value: "\(firestoreManager.userStats?.dailyGoal.water ?? 8) cups")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .animation(.default, value: isEditingGoals)
                    
                    // Workout Reminder Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Workout Reminders")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                showingReminderSheet = true
                            }) {
                                Image(systemName: "bell.badge")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        
                        ProfileRow(icon: "bell.fill", title: "Daily Reminder", value: formatTime(reminderTime))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50) // Add spacer to prevent logout button from going below
                    
                    // Sign Out Button
                    Button(action: {
                        authManager.signOut()
                    }) {
                        Text("Sign Out")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                    .buttonStyle(BorderlessButtonStyle()) // Fix button style glitch
                }
                .frame(minHeight: UIScreen.main.bounds.height - 100) // Ensure minimum content height
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: $inputImage)
            }
            .sheet(isPresented: $showingReminderSheet) {
                ReminderSettingView(reminderTime: $reminderTime)
            }
            .overlay {
                if isUploading {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        .scaleEffect(2)
                }
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(firestoreManager.errorMessage ?? "Unknown error occurred")
            }
            .onAppear(perform: loadProfileData)
        }
        .navigationBarHidden(true)
    }
    
    // Helper function to get safe area inset in a way that works on iOS 15+
    private func getTopSafeAreaInset() -> CGFloat {
        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            return windowScene?.windows.first?.safeAreaInsets.top ?? 0
        } else {
            return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        }
    }
    
    private var profilePhotoView: some View {
        Group {
            if let profileImage = profileImage {
                profileImage
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } else if let photoURL = authManager.user?.photoURL {
                AsyncImage(url: photoURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
        uploadProfileImage(inputImage)
    }
    
    private func uploadProfileImage(_ image: UIImage) {
        guard let uid = authManager.user?.uid else { return }
        isUploading = true
        
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("profile_images/\(uid).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            isUploading = false
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(imageData, metadata: metadata) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    firestoreManager.errorMessage = error.localizedDescription
                    showingErrorAlert = true
                    isUploading = false
                    return
                }
                
                imageRef.downloadURL { url, error in
                    DispatchQueue.main.async {
                        isUploading = false
                        if let error = error {
                            print("Error getting download URL: \(error.localizedDescription)")
                            firestoreManager.errorMessage = error.localizedDescription
                            showingErrorAlert = true
                            return
                        }
                        
                        guard let downloadURL = url else { return }
                        print("Image uploaded successfully: \(downloadURL.absoluteString)")
                        updateUserProfile(photoURL: downloadURL)
                        
                        // Send notification
                        firestoreManager.sendNotification(
                            title: "Profile Updated",
                            body: "Your profile photo has been updated successfully!"
                        )
                    }
                }
            }
        }
    }
    
    private func updateUserProfile(photoURL: URL) {
        let changeRequest = authManager.user?.createProfileChangeRequest()
        changeRequest?.photoURL = photoURL
        changeRequest?.commitChanges { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error updating profile: \(error.localizedDescription)")
                    firestoreManager.errorMessage = error.localizedDescription
                    showingErrorAlert = true
                } else {
                    print("Profile photo URL updated successfully")
                    // Also update the URL in Firestore for better data consistency
                    if let userId = authManager.user?.uid, var stats = firestoreManager.userStats {
                        stats.photoURL = photoURL.absoluteString
                        firestoreManager.updateUserStats(userId: userId, stats: stats)
                    }
                }
            }
        }
    }
    
    private func saveProfile() {
        guard let user = authManager.user else { return }
        print("Saving profile with name: \(displayName), bio: \(bio)")
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        
        changeRequest.commitChanges { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error updating display name: \(error.localizedDescription)")
                    firestoreManager.errorMessage = error.localizedDescription
                    showingErrorAlert = true
                } else {
                    print("Display name updated successfully")
                    // Update bio in Firestore
                    let userId = user.uid
                    if var stats = firestoreManager.userStats {
                        stats.bio = bio
                        firestoreManager.updateUserStats(userId: userId, stats: stats)
                        
                        // Send notification
                        firestoreManager.sendNotification(
                            title: "Profile Updated",
                            body: "Your profile information has been updated successfully!"
                        )
                    }
                }
            }
        }
    }
    
    private func saveGoals() {
        guard let userId = authManager.user?.uid,
              var stats = firestoreManager.userStats else { return }
        
        print("Saving goals: steps=\(stepsGoal), calories=\(caloriesGoal), minutes=\(activeMinutesGoal), water=\(waterGoal)")
        
        // Update goals with new values
        if let steps = Int(stepsGoal), steps > 0 {
            stats.dailyGoal.steps = steps
        }
        
        if let calories = Int(caloriesGoal), calories > 0 {
            stats.dailyGoal.calories = calories
        }
        
        if let minutes = Int(activeMinutesGoal), minutes > 0 {
            stats.dailyGoal.activeMinutes = minutes
        }
        
        if let water = Int(waterGoal), water > 0 {
            stats.dailyGoal.water = water
        }
        
        // Save to Firestore with completion handler
        firestoreManager.updateUserStats(userId: userId, stats: stats) { success in
            DispatchQueue.main.async {
                if success {
                    // Refresh local data to ensure UI updates
                    self.loadProfileData()
                    
                    // Send notification
                    self.firestoreManager.sendNotification(
                        title: "Goals Updated",
                        body: "Your fitness goals have been updated successfully!"
                    )
                } else {
                    self.showingErrorAlert = true
                }
                self.isEditingGoals = false
            }
        }
    }
    
    private func loadProfileData() {
        if let user = authManager.user {
            displayName = user.displayName ?? ""
            
            // Try to load profile image from URL
            if let photoURL = user.photoURL {
                // We'll use AsyncImage in the view instead of loading here
                print("User has profile photo URL: \(photoURL.absoluteString)")
            }
            
            bio = firestoreManager.userStats?.bio ?? ""
            
            // Load goal values
            if let stats = firestoreManager.userStats {
                stepsGoal = "\(stats.dailyGoal.steps)"
                caloriesGoal = "\(stats.dailyGoal.calories)"
                activeMinutesGoal = "\(stats.dailyGoal.activeMinutes)"
                waterGoal = "\(stats.dailyGoal.water)"
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - ProfileRow
struct ProfileRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.red)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - GoalEditRow
struct GoalEditRow: View {
    var title: String
    @Binding var value: String
    var unit: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            TextField("", text: $value)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.white)
                .frame(width: 80)
            
            Text(unit)
                .foregroundColor(.gray)
                .frame(width: 50, alignment: .leading)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}

// MARK: - ReminderSettingView
struct ReminderSettingView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var reminderTime: Date
    @State private var isReminderEnabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Workout Reminder")) {
                    Toggle("Enable Reminder", isOn: $isReminderEnabled)
                    
                    if isReminderEnabled {
                        DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section {
                    Button("Save") {
                        if isReminderEnabled {
                            scheduleReminder()
                        } else {
                            cancelReminders()
                        }
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Workout Reminder")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func scheduleReminder() {
        let center = UNUserNotificationCenter.current()
        
        // Request permission
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                // Create notification content
                let content = UNMutableNotificationContent()
                content.title = "Time to Workout!"
                content.body = "Don't forget your fitness goals for today."
                content.sound = .default
                
                // Create time components
                let calendar = Calendar.current
                let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
                
                // Create trigger
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                
                // Create request
                let request = UNNotificationRequest(
                    identifier: "dailyWorkoutReminder",
                    content: content,
                    trigger: trigger
                )
                
                // Add request to notification center
                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling reminder: \(error.localizedDescription)")
                    } else {
                        print("Reminder scheduled for \(components.hour ?? 0):\(components.minute ?? 0)")
                    }
                }
            }
        }
    }
    
    private func cancelReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyWorkoutReminder"])
    }
}

// MARK: - ImagePicker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
    }
}

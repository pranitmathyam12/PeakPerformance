import Firebase
import FirebaseFirestore
import UserNotifications

class FirestoreManager: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var workouts: [Workout] = []
    @Published var foodEntries: [FoodEntry] = []
    @Published var userStats: UserStats?
    @Published var nutritionSummary: NutritionSummary = NutritionSummary()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - User Stats Operations
    func fetchUserStats(userId: String) {
        isLoading = true
        
        db.collection("users").document(userId)
            .getDocument { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = "Error fetching user stats: \(error.localizedDescription)"
                        print("Error fetching user stats: \(error)")
                        return
                    }
                    
                    if let snapshot = snapshot, snapshot.exists {
                        do {
                            // Use Firestore's built-in Codable support
                            let stats = try snapshot.data(as: UserStats.self)
                            print("Successfully fetched user stats")
                            self.userStats = stats
                            self.errorMessage = nil
                        } catch {
                            self.errorMessage = "Error parsing user data: \(error.localizedDescription)"
                            print("Error parsing user data: \(error)")
                        }
                    } else {
                        // If no data exists, create default stats
                        self.createDefaultUserStats(userId: userId)
                    }
                }
            }
    }
    
    private func createDefaultUserStats(userId: String) {
        let defaultStats = UserStats(
            userId: userId,
            dailySteps: 0,
            caloriesBurned: 0,
            caloriesConsumed: 0,
            activeMinutes: 0,
            distanceWalked: 0.0,
            waterIntake: 0,
            bio: "",
            dailyGoal: DailyGoal()
        )
        
        do {
            try db.collection("users").document(userId).setData(from: defaultStats)
            
            DispatchQueue.main.async {
                self.userStats = defaultStats
                print("Created default user stats for user: \(userId)")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error creating default stats: \(error.localizedDescription)"
                print("Error creating default stats: \(error)")
            }
        }
    }
    
    func updateUserStats(userId: String, stats: UserStats, completion: @escaping (Bool) -> Void = { _ in }) {
        isLoading = true
        
        do {
            // Use Firestore's built-in Codable support with merge: true
            try db.collection("users").document(userId).setData(from: stats, merge: true) { [weak self] error in
                guard let self = self else {
                    completion(false)
                    return
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "Error updating stats: \(error.localizedDescription)"
                        print("Error updating stats: \(error)")
                        completion(false)
                    }
                } else {
                    print("Successfully updated user stats in Firestore")
                    
                    // Get the latest data directly from Firestore to ensure we have the most up-to-date version
                    self.db.collection("users").document(userId).getDocument { snapshot, error in
                        DispatchQueue.main.async {
                            self.isLoading = false
                            
                            if let error = error {
                                self.errorMessage = "Error fetching updated stats: \(error.localizedDescription)"
                                print("Error fetching updated stats: \(error)")
                                completion(false)
                                return
                            }
                            
                            if let snapshot = snapshot, snapshot.exists {
                                do {
                                    // Update the local userStats with the latest data from Firestore
                                    let updatedStats = try snapshot.data(as: UserStats.self)
                                    self.userStats = updatedStats
                                    print("Successfully refreshed user stats")
                                    self.errorMessage = nil
                                    
                                    // Delay the completion to ensure UI has time to update
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        completion(true)
                                    }
                                } catch {
                                    self.errorMessage = "Error parsing updated stats: \(error.localizedDescription)"
                                    print("Error parsing updated stats: \(error)")
                                    completion(false)
                                }
                            } else {
                                self.errorMessage = "Updated stats document not found"
                                print("Updated stats document not found")
                                completion(false)
                            }
                        }
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Error encoding stats: \(error.localizedDescription)"
                print("Error encoding stats: \(error)")
                completion(false)
            }
        }
    }
    
    // Function to update a specific stat
    func updateStat(userId: String, field: String, value: Any) {
        guard userStats != nil else {
            print("Cannot update stats: No user stats loaded")
            return
        }
        
        db.collection("users").document(userId).updateData([
            field: value
        ]) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error updating \(field): \(error)")
                    self?.errorMessage = "Error updating \(field): \(error.localizedDescription)"
                } else {
                    self?.errorMessage = nil
                    print("Successfully updated \(field) to \(value)")
                }
            }
        }
    }
    
    // MARK: - Workout CRUD Operations
    func fetchWorkouts(userId: String) {
        isLoading = true
        
        db.collection("workouts")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        print("Error fetching workouts: \(error)")
                        return
                    }
                    
                    // Use Firestore's built-in Codable support
                    self.workouts = snapshot?.documents.compactMap { document in
                        try? document.data(as: Workout.self)
                    } ?? []
                    
                    self.errorMessage = nil
                }
            }
    }
    
    func addWorkout(userId: String, workout: Workout, completion: @escaping (Bool) -> Void = { _ in }) {
        isLoading = true
        var newWorkout = workout
        newWorkout.userId = userId
        
        do {
            // Use Firestore's built-in Codable support
            let docRef = try db.collection("workouts").addDocument(from: newWorkout)
            
            docRef.getDocument { [weak self] document, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        print("Error adding workout: \(error)")
                        completion(false)
                    } else {
                        self.errorMessage = nil
                        if let document = document, let workout = try? document.data(as: Workout.self) {
                            self.updateUserStatsAfterWorkout(userId: userId, workout: workout)
                            self.sendNotification(
                                title: "Workout Added",
                                body: "Your \(workout.name) workout has been added successfully!"
                            )
                        }
                        completion(true)
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Error encoding workout: \(error.localizedDescription)"
                print("Error encoding workout: \(error)")
                completion(false)
            }
        }
    }
    
    func updateWorkout(userId: String, workoutId: String, workout: Workout, completion: @escaping (Bool) -> Void = { _ in }) {
        isLoading = true
        
        do {
            try db.collection("workouts").document(workoutId).setData(from: workout) { [weak self] error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        print("Error updating workout: \(error)")
                        completion(false)
                    } else {
                        self.errorMessage = nil
                        self.sendNotification(
                            title: "Workout Updated",
                            body: "Your \(workout.name) workout has been updated successfully!"
                        )
                        completion(true)
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Error encoding workout: \(error.localizedDescription)"
                print("Error encoding workout: \(error)")
                completion(false)
            }
        }
    }
    
    private func updateUserStatsAfterWorkout(userId: String, workout: Workout) {
        db.runTransaction { [weak self] transaction, errorPointer in
            let userRef = self?.db.collection("users").document(userId)
            guard let userRef = userRef else { return nil }
            
            do {
                let snapshot = try transaction.getDocument(userRef)
                
                // If document doesn't exist, create default stats
                guard var stats = try? snapshot.data(as: UserStats.self) else {
                    errorPointer?.pointee = NSError(domain: "AppError", code: 500, userInfo: [
                        NSLocalizedDescriptionKey: "Could not decode user stats"
                    ])
                    return nil
                }
                
                // Update stats with workout data
                stats.caloriesBurned += workout.calories
                stats.activeMinutes += workout.duration
                
                // Update document in transaction
                try transaction.setData(from: stats, forDocument: userRef, merge: true)
                
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        } completion: { [weak self] _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Error updating stats: \(error.localizedDescription)"
                    print("Transaction error: \(error)")
                }
            }
        }
    }
    
    func deleteWorkout(userId: String, workoutId: String, completion: @escaping (Bool) -> Void = { _ in }) {
        db.collection("workouts").document(workoutId).delete { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("Error deleting workout: \(error)")
                    completion(false)
                } else {
                    self?.errorMessage = nil
                    self?.sendNotification(
                        title: "Workout Deleted",
                        body: "Your workout has been deleted successfully."
                    )
                    completion(true)
                }
            }
        }
    }
    
    // MARK: - Food Entry CRUD Operations
    func fetchFoodEntries(userId: String, date: Date? = nil) {
        isLoading = true
        
        var query = db.collection("foodEntries").whereField("userId", isEqualTo: userId)
        
        if let date = date {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            query = query.whereField("date", isGreaterThanOrEqualTo: startOfDay)
                         .whereField("date", isLessThan: endOfDay)
        }
        
        query.order(by: "date", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        print("Error fetching food entries: \(error)")
                        return
                    }
                    
                    // Use getDocuments instead of addSnapshotListener to avoid duplicate updates
                    if let documents = snapshot?.documents {
                        self.foodEntries = documents.compactMap { document -> FoodEntry? in
                            // Create a food entry with the document ID explicitly set
                            var entry = try? document.data(as: FoodEntry.self)
                            if entry?.id == nil {
                                entry?.id = document.documentID
                            }
                            return entry
                        }
                        
                        // Check for nil IDs and log them
                        let nilIdCount = self.foodEntries.filter { $0.id == nil }.count
                        if nilIdCount > 0 {
                            print("Warning: Found \(nilIdCount) food entries with nil IDs")
                        }
                        
                        self.calculateNutritionSummary()
                    }
                }
            }
    }
    
    func addFoodEntry(userId: String, foodEntry: FoodEntry, completion: @escaping (Bool) -> Void = { _ in }) {
        isLoading = true
        var newEntry = foodEntry
        newEntry.userId = userId
        
        do {
            // Use Firestore's built-in Codable support
            let docRef = try db.collection("foodEntries").addDocument(from: newEntry)
            
            docRef.getDocument { [weak self] document, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        print("Error adding food entry: \(error)")
                        completion(false)
                    } else {
                        self.errorMessage = nil
                        self.updateUserNutritionStats(userId: userId, calories: newEntry.calories)
                        self.sendNotification(
                            title: "Food Entry Added",
                            body: "Your \(newEntry.name) has been logged successfully!"
                        )
                        
                        // Refresh food entries
                        self.fetchFoodEntries(userId: userId, date: newEntry.date)
                        completion(true)
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Error encoding food entry: \(error.localizedDescription)"
                print("Error encoding food entry: \(error)")
                completion(false)
            }
        }
    }
    
    func updateFoodEntry(userId: String, entryId: String, entry: FoodEntry, completion: @escaping (Bool) -> Void = { _ in }) {
        isLoading = true
        
        // Get the original entry to calculate calorie difference
        if let originalEntry = foodEntries.first(where: { $0.id == entryId }) {
            let calorieDifference = entry.calories - originalEntry.calories
            
            do {
                // Update the document in Firestore
                try db.collection("foodEntries").document(entryId).setData(from: entry) { [weak self] error in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        self.isLoading = false
                        
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                            print("Error updating food entry: \(error)")
                            completion(false)
                        } else {
                            self.errorMessage = nil
                            
                            // Only update nutrition stats if calories changed
                            if calorieDifference != 0 {
                                self.updateUserNutritionStats(userId: userId, calories: calorieDifference)
                            }
                            
                            // Refresh food entries
                            self.fetchFoodEntries(userId: userId, date: entry.date)
                            
                            self.sendNotification(
                                title: "Food Entry Updated",
                                body: "Your \(entry.name) has been updated successfully!"
                            )
                            
                            completion(true)
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Error encoding food entry: \(error.localizedDescription)"
                    print("Error encoding food entry: \(error)")
                    completion(false)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Original food entry not found"
                print("Original food entry not found")
                completion(false)
            }
        }
    }
    
    func deleteFoodEntry(userId: String, entryId: String, completion: @escaping (Bool) -> Void = { _ in }) {
        // First check if the entry exists in our local array
        guard let entryIndex = foodEntries.firstIndex(where: { $0.id == entryId }) else {
            print("Food entry with ID \(entryId) not found locally")
            completion(false)
            return
        }
        
        let entry = foodEntries[entryIndex]
        print("Deleting food entry: \(entryId), calories: \(entry.calories)")
        
        // Remove from local array first to update UI immediately
        DispatchQueue.main.async {
            self.foodEntries.remove(at: entryIndex)
            self.calculateNutritionSummary()
        }
        
        // Delete the document from Firestore
        db.collection("foodEntries").document(entryId).delete { [weak self] error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Error deleting food entry: \(error)")
                    
                    // If deletion failed, add the entry back to the array
                    self.foodEntries.insert(entry, at: entryIndex)
                    self.calculateNutritionSummary()
                    completion(false)
                } else {
                    // Subtract the calories from the user's total
                    self.updateUserNutritionStats(userId: userId, calories: -entry.calories)
                    
                    self.sendNotification(
                        title: "Food Entry Deleted",
                        body: "Your food entry has been deleted successfully."
                    )
                    
                    self.errorMessage = nil
                    completion(true)
                }
            }
        }
    }
    
    private func updateUserNutritionStats(userId: String, calories: Int) {
        db.runTransaction { [weak self] transaction, errorPointer in
            let userRef = self?.db.collection("users").document(userId)
            guard let userRef = userRef else { return nil }
            
            do {
                let snapshot = try transaction.getDocument(userRef)
                
                guard var stats = try? snapshot.data(as: UserStats.self) else {
                    errorPointer?.pointee = NSError(domain: "AppError", code: 500, userInfo: [
                        NSLocalizedDescriptionKey: "Could not decode user stats"
                    ])
                    return nil
                }
                
                // Update stats with food entry data
                stats.caloriesConsumed = (stats.caloriesConsumed ?? 0) + calories
                
                // Update document in transaction
                try transaction.setData(from: stats, forDocument: userRef, merge: true)
                
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        } completion: { [weak self] _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Error updating nutrition stats: \(error.localizedDescription)"
                    print("Transaction error: \(error)")
                }
            } else {
                // Refresh user stats to update the UI
                if let userId = self?.userStats?.userId {
                    DispatchQueue.main.async {
                        self?.fetchUserStats(userId: userId)
                    }
                }
            }
        }
    }
    
    private func calculateNutritionSummary() {
        var summary = NutritionSummary()
        
        for entry in foodEntries {
            summary.totalCalories += entry.calories
            summary.totalProtein += entry.protein
            summary.totalCarbs += entry.carbs
            summary.totalFat += entry.fat
        }
        
        // Calculate remaining calories based on user's daily goal
        let dailyCalorieGoal = userStats?.dailyGoal.caloriesIntake ?? 2000
        summary.remainingCalories = dailyCalorieGoal - summary.totalCalories
        
        nutritionSummary = summary
    }
    
    // MARK: - Notifications
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func loginSuccessNotification(userName: String) {
        sendNotification(
            title: "Welcome Back!",
            body: "You've successfully logged in to PeakPerformance, \(userName)."
        )
    }
    
    // MARK: - Reminder Notifications
    func scheduleWorkoutReminder(at time: Date) {
        let center = UNUserNotificationCenter.current()
        
        // Request permission with more robust handling
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                // Create notification content with more engaging text
                let content = UNMutableNotificationContent()
                content.title = "Time to Workout! 💪"
                content.subtitle = "Your daily fitness reminder"
                content.body = "Don't forget your fitness goals for today. Let's crush it!"
                content.sound = .default
                content.badge = 1
                
                // Create time components
                let calendar = Calendar.current
                let components = calendar.dateComponents([.hour, .minute], from: time)
                
                print("Scheduling reminder for \(components.hour ?? 0):\(components.minute ?? 0)")
                
                // Create trigger
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                
                // Create request with fixed identifier for easy management
                let request = UNNotificationRequest(
                    identifier: "dailyWorkoutReminder",
                    content: content,
                    trigger: trigger
                )
                
                // Remove any existing reminders first
                center.removePendingNotificationRequests(withIdentifiers: ["dailyWorkoutReminder"])
                
                // Add request to notification center
                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling reminder: \(error.localizedDescription)")
                    } else {
                        print("Reminder successfully scheduled for \(components.hour ?? 0):\(components.minute ?? 0)")
                    }
                }
            } else if let error = error {
                print("Permission denied for notifications: \(error.localizedDescription)")
            } else {
                print("Permission denied for notifications")
            }
        }
    }
    
    func scheduleTestNotification() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Test Notification 🔔"
                content.subtitle = "This is a test"
                content.body = "Your notifications are working correctly!"
                content.sound = .default
                
                // Show notification 5 seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                
                let request = UNNotificationRequest(
                    identifier: "testNotification",
                    content: content,
                    trigger: trigger
                )
                
                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling test notification: \(error.localizedDescription)")
                    } else {
                        print("Test notification scheduled successfully")
                    }
                }
            }
        }
    }
    
    func cancelWorkoutReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyWorkoutReminder"])
        print("Workout reminders cancelled")
    }
}

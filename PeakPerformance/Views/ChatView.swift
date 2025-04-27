import SwiftUI

struct ChatView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @StateObject var viewModel = ChatViewModel()
    @State private var newMessage = ""
    @State private var showingCaloriePrompt = false
    @State private var timeAvailable: String = ""
    @State private var preferences: String = ""
    @State private var showingErrorAlert = false
    @State private var hasInitialized = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom header
                    HStack {
                        Spacer()
                        
                        Text("AI Coach")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, getTopSafeAreaInset())
                    .padding(.bottom, 10)
                    .background(Color.black.opacity(0.95))
                    
                    // Chat content
                    VStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .red))
                                .scaleEffect(1.5)
                                .padding()
                        }
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6).opacity(0.5))
                                .cornerRadius(8)
                                .padding(.horizontal)
                                .padding(.top, 4)
                                .onTapGesture {
                                    viewModel.errorMessage = nil
                                }
                        }
                        
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.messages) { message in
                                        MessageRow(message: message)
                                            .id(message.id)
                                    }
                                    
                                    // Invisible spacer view to scroll to
                                    Color.clear
                                        .frame(height: 1)
                                        .id("bottomID")
                                }
                                .padding(.horizontal)
                                .padding(.top, 10)
                            }
                            .onChange(of: viewModel.messages.count) { _, _ in
                                withAnimation {
                                    proxy.scrollTo("bottomID", anchor: .bottom)
                                }
                            }
                        }
                        
                        Divider()
                            .background(Color.gray)
                        
                        // Input area
                        VStack {
                            HStack {
                                Button(action: {
                                    showingCaloriePrompt = true
                                }) {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.red)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                }
                                
                                TextField("Message", text: $newMessage)
                                    .padding(10)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(20)
                                    .foregroundColor(.white)
                                    .submitLabel(.send)
                                    .onSubmit {
                                        if !newMessage.isEmpty {
                                            viewModel.send(text: newMessage)
                                            newMessage = ""
                                        }
                                    }
                                
                                Button(action: {
                                    if !newMessage.isEmpty {
                                        viewModel.send(text: newMessage)
                                        newMessage = ""
                                    }
                                }) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.red)
                                }
                                .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                        .background(Color.black)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationViewStyle(StackNavigationViewStyle())
            .sheet(isPresented: $showingCaloriePrompt) {
                CaloriePromptView(viewModel: viewModel,
                                  remainingCalories: getRemainingCalories(),
                                  timeAvailable: $timeAvailable,
                                  preferences: $preferences)
            }
            .onAppear {
                print("ChatView appeared")
                if !hasInitialized {
                    viewModel.initialize()
                    
                    // Add welcome message if needed
                    if viewModel.messages.isEmpty {
                        viewModel.messages.append(Message(
                            text: "Hello! I'm your fitness assistant. I can help you with workout suggestions to meet your calorie goals. Tap the flame icon to get started.",
                            isCurrentUser: false
                        ))
                    }
                    hasInitialized = true
                }
            }
            .onChange(of: viewModel.errorMessage) { _, newValue in
                showingErrorAlert = newValue != nil
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                } else {
                    Text("An unknown error occurred")
                }
            }
        }
    }
    
    private func getRemainingCalories() -> Int {
        let dailyGoal = firestoreManager.userStats?.dailyGoal.calories ?? 500
        let burned = firestoreManager.userStats?.caloriesBurned ?? 0
        return max(0, dailyGoal - burned)
    }
    
    // Helper function to get safe area inset
    private func getTopSafeAreaInset() -> CGFloat {
        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            return windowScene?.windows.first?.safeAreaInsets.top ?? 0
        } else {
            return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        }
    }
}

struct MessageRow: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isCurrentUser {
                Spacer()
                Text(message.text)
                    .padding(12)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .cornerRadius(16, corners: [.topRight, .bottomLeft, .bottomRight])
            } else {
                Text(message.text)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .cornerRadius(16, corners: [.topRight, .topLeft, .bottomRight])
                Spacer()
            }
        }
    }
}

struct CaloriePromptView: View {
    @Environment(\.dismiss) var dismiss
    var viewModel: ChatViewModel
    let remainingCalories: Int
    @Binding var timeAvailable: String
    @Binding var preferences: String
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Form {
                    Section(header: Text("Calories to Burn")) {
                        Text("\(remainingCalories) calories")
                            .foregroundColor(.red)
                            .font(.headline)
                    }
                    
                    Section(header: Text("Time Available (minutes)")) {
                        TextField("Optional", text: $timeAvailable)
                            .keyboardType(.numberPad)
                            .foregroundColor(.white)
                    }
                    
                    Section(header: Text("Workout Preferences")) {
                        TextField("e.g., home workout, no equipment", text: $preferences)
                            .foregroundColor(.white)
                    }
                    
                    Section {
                        Button("Get Suggestions") {
                            let time = Int(timeAvailable) ?? 0
                            viewModel.getWorkoutSuggestions(
                                remainingCalories: remainingCalories,
                                timeAvailable: time > 0 ? time : nil,
                                preferences: preferences.isEmpty ? nil : preferences
                            )
                            dismiss()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.red)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Workout Suggestions")
                .navigationBarItems(trailing: Button("Cancel") {
                    dismiss()
                })
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}



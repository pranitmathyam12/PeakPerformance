import SwiftUI
import Foundation

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isCurrentUser: Bool
}

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var currentInput: String = ""
    @Published var isInitialized = false
    @Published var errorMessage: String? = nil
    
    func initialize() {
        // Only initialize once
        guard !isInitialized else {
            print("ChatViewModel already initialized, skipping")
            return
        }
        
        isInitialized = true
        print("ChatViewModel initialized with direct API implementation")
        
        // Test the connection to verify API key works
        testConnection()
    }
    
    private func testConnection() {
        let testPrompt = "Hello, this is a test. Please respond with a short greeting."
        sendDirectAPIRequest(prompt: testPrompt, isTest: true)
    }
    
    func getWorkoutSuggestions(remainingCalories: Int, timeAvailable: Int? = nil, preferences: String? = nil) {
        isLoading = true
        errorMessage = nil
        
        var prompt = "I need to burn \(remainingCalories) more calories today to meet my fitness goal."
        
        if let time = timeAvailable {
            prompt += " I have \(time) minutes available."
        }
        
        if let prefs = preferences, !prefs.isEmpty {
            prompt += " My workout preferences: \(prefs)."
        }
        
        prompt += " Suggest specific workouts with estimated calorie burn."
        
        messages.append(Message(text: prompt, isCurrentUser: true))
        print("Sending workout suggestion request: \(prompt)")
        
        sendDirectAPIRequest(prompt: prompt)
    }
    
    func send(text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        messages.append(Message(text: text, isCurrentUser: true))
        print("Sending message: \(text)")
        
        sendDirectAPIRequest(prompt: text)
    }
    
    // Direct API implementation to bypass library issues
    private func sendDirectAPIRequest(prompt: String, isTest: Bool = false) {
        let apiKey = "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"
        
        // Use the chat completions endpoint instead of completions
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Format for chat completions API - gpt-3.5-turbo requires this format
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": isTest ? 50 : 500,
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("Error creating request body: \(error)")
            self.errorMessage = "Error creating request: \(error.localizedDescription)"
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("API error: \(error)")
                    self?.errorMessage = "API Error: \(error.localizedDescription)"
                    if !isTest {
                        self?.messages.append(Message(text: "Error: \(error.localizedDescription)", isCurrentUser: false))
                    }
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    self?.errorMessage = "No data received from API"
                    if !isTest {
                        self?.messages.append(Message(text: "No response received. Please try again.", isCurrentUser: false))
                    }
                    return
                }
                
                do {
                    if let httpResponse = response as? HTTPURLResponse {
                        print("HTTP Status Code: \(httpResponse.statusCode)")
                        
                        if httpResponse.statusCode != 200 {
                            // Try to parse error message
                            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let errorMessage = errorJson["error"] as? [String: Any],
                               let message = errorMessage["message"] as? String {
                                print("API Error: \(message)")
                                self?.errorMessage = "API Error: \(message)"
                                if !isTest {
                                    self?.messages.append(Message(text: "Error: \(message)", isCurrentUser: false))
                                }
                                return
                            }
                        }
                    }
                    
                    // Parse the chat completions response format
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if let choices = json?["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        let trimmedText = content.trimmingCharacters(in: .whitespacesAndNewlines)
                        print("Received response: \(trimmedText)")
                        if isTest {
                            print("✅ API Connection Test Successful")
                        } else {
                            self?.messages.append(Message(text: trimmedText, isCurrentUser: false))
                        }
                    } else {
                        print("Could not parse response")
                        self?.errorMessage = "Could not parse API response"
                        if !isTest {
                            self?.messages.append(Message(text: "No response received. Please try again.", isCurrentUser: false))
                        }
                    }
                } catch {
                    print("Error parsing response: \(error)")
                    self?.errorMessage = "Error parsing response: \(error.localizedDescription)"
                    if !isTest {
                        self?.messages.append(Message(text: "Error: \(error.localizedDescription)", isCurrentUser: false))
                    }
                }
            }
        }.resume()
    }
}

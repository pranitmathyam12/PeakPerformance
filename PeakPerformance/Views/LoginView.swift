//
//  LoginView.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/24/25.
//

// LoginView.swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                Image(systemName: "figure.run")
                    .font(.system(size: 70))
                    .foregroundColor(.red)
                    .padding(.bottom, 20)
                
                Text("PeakPerformance")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 25)
                
                Button(action: {
                    if isRegistering {
                        authManager.signUp(email: email, password: password)
                    } else {
                        authManager.signIn(email: email, password: password)
                    }
                }) {
                    Text(isRegistering ? "Register" : "Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 25)
                .disabled(email.isEmpty || password.isEmpty || authManager.isLoading)
                
                Button(action: {
                    isRegistering.toggle()
                }) {
                    Text(isRegistering ? "Already have an account? Login" : "Don't have an account? Register")
                        .foregroundColor(.gray)
                }
                
                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if authManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        .scaleEffect(1.5)
                }
            }
        }
    }
}

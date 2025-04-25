import Foundation
import LocalAuthentication
import SwiftUI

// User model to store user details
struct User: Codable {
    let username: String
    let email: String
    let phone: String
    let location: String
    // Note: even though the password is returned from the server,
    // we typically wouldn't want to store it in our client app model
}

// Response model for login
struct LoginResponse: Codable {
    let message: String
    let user: User
}

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var showSignUp: Bool = false
    @Published var showDashboard: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentUser: User? = nil
    
    // MARK: - Login Actions
    
    func login() {
        guard let url = URL(string: "http://169.254.83.18:3000/login") else {
            self.errorMessage = "Invalid login URL"
            return
        }
        
        let loginPayload = ["username": username, "password": password]
        guard let body = try? JSONSerialization.data(withJSONObject: loginPayload) else {
            self.errorMessage = "Failed to encode login data"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid response from server"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received from server"
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    do {
                        let decoder = JSONDecoder()
                        let loginResponse = try decoder.decode(LoginResponse.self, from: data)
                        
                        // Store the user details
                        self.currentUser = loginResponse.user
                        self.errorMessage = nil
                        self.isAuthenticated = true
                        self.showDashboard = true
                        
                        // You could also save user details to UserDefaults here if needed
                        // self.saveUserToUserDefaults(user: loginResponse.user)
                        
                    } catch {
                        self.errorMessage = "Failed to parse server response: \(error.localizedDescription)"
                    }
                } else {
                    // Try to extract error message if available
                    do {
                        if let errorResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let message = errorResponse["message"] as? String {
                            self.errorMessage = message
                        } else {
                            self.errorMessage = "Invalid credentials. Please try again."
                        }
                    } catch {
                        self.errorMessage = "Invalid credentials. Please try again."
                    }
                }
            }
        }.resume()
    }
    
    func loginWithApple() {
        print("Apple login")
        self.showDashboard = true
    }
    
    func loginWithGoogle() {
        print("Google login")
        self.showDashboard = true
    }
    
    func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Log in using Face ID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                        print("✅ Face ID success")
                        self.showDashboard = true
                    } else {
                        print("❌ Face ID failed: \(authError?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        } else {
            print("⚠️ Face ID not available: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    // Optional: Save user to UserDefaults for persistence
    private func saveUserToUserDefaults(user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
}

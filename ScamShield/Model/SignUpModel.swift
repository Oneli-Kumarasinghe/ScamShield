import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var isConfirmPasswordVisible: Bool = false
    @Published var showLogin: Bool = false
    
    // You can remove this if you no longer need Dashboard navigation
    // @Published var showDashboard: Bool = false

    func signUp() {
        // Your sign-up logic here
        
        // After successful sign-up, navigate to Login instead of Dashboard
        showLogin = true
    }

    func signUpWithApple() {
        // Apple sign-up logic here
        
        // After successful Apple sign-up, navigate to Login instead of Dashboard
        showLogin = true
    }

    func signUpWithGoogle() {
        // Google sign-up logic here
        
        // After successful Google sign-up, navigate to Login instead of Dashboard
        showLogin = true
    }

    func navigateToLogin() {
        showLogin = true
    }
}

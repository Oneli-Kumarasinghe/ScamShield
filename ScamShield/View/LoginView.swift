import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Enter your credential to continue")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 15)

                // Email field
                TextField("username", text: $viewModel.username)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                // Password field with toggle button
                ZStack(alignment: .trailing) {
                    Group {
                        if viewModel.isPasswordVisible {
                            TextField("Password", text: $viewModel.password)
                        } else {
                            SecureField("Password", text: $viewModel.password)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    Button(action: {
                        viewModel.isPasswordVisible.toggle()
                    }) {
                        Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye")
                            .padding()
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)

                // Forgot password
                Button("Forgot password?") {
                    // Handle forgot password
                }
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal)

                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                }

                // Login button
                Button(action: {
                    viewModel.login()
                }) {
                    Text("Log in")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(25)
                }
                .padding(.horizontal)

                // Apple login
                Button(action: {
                    viewModel.loginWithApple()
                }) {
                    Label("Log in using Apple", systemImage: "applelogo")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(25)
                }
                .padding(.horizontal)

                // Google login
                Button(action: {
                    viewModel.loginWithGoogle()
                }) {
                    HStack {
                        Image("google_logo")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Log in using Google")
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(25)
                }
                .padding(.horizontal)

                // Face ID
                Button(action: {
                    viewModel.authenticateWithFaceID()
                }) {
                    Label("Log in with Face ID", systemImage: "faceid")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(25)
                }
                .padding(.horizontal)

                Spacer()

            }
            .padding(.top)

            // Navigation to Dashboard
            .background(
                NavigationLink(destination: DashboardView(user: viewModel.currentUser), isActive: $viewModel.showDashboard) {
                    EmptyView()
                }
            )
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

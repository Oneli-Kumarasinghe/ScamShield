import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Create account")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Sign up to get started!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 15)

                // Username
                TextField("Username", text: $viewModel.username)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                // Email
                TextField("Email address", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                // Password
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

                    Button {
                        viewModel.isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye")
                            .padding()
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)

                // Confirm Password
                ZStack(alignment: .trailing) {
                    Group {
                        if viewModel.isConfirmPasswordVisible {
                            TextField("Confirm password", text: $viewModel.confirmPassword)
                        } else {
                            SecureField("Confirm password", text: $viewModel.confirmPassword)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    Button {
                        viewModel.isConfirmPasswordVisible.toggle()
                    } label: {
                        Image(systemName: viewModel.isConfirmPasswordVisible ? "eye.slash" : "eye")
                            .padding()
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)

                // Sign Up Button
                Button {
                    viewModel.signUp()
                } label: {
                    Text("Sign up")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(25)
                }
                .padding(.horizontal)

                // Apple Sign Up
                Button {
                    viewModel.signUpWithApple()
                } label: {
                    Label("Sign up using Apple", systemImage: "applelogo")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(25)
                }
                .padding(.horizontal)

                // Google Sign Up
                Button {
                    viewModel.signUpWithGoogle()
                } label: {
                    HStack {
                        Image("google_logo")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Sign up using Google")
                            .foregroundColor(.primary)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(25)
                }
                .padding(.horizontal)

                Spacer()

                // Already have account
                VStack {
                    Text("Already member?")
                        .foregroundColor(.gray)

                    Text("Log in")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            viewModel.navigateToLogin()
                        }
                }
                .font(.footnote)
                .padding(.bottom, 16)
            }
            .padding(.top)
            
            
            .background(
                NavigationLink(destination: LoginView(), isActive: $viewModel.showLogin) { EmptyView() }
            )
            
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

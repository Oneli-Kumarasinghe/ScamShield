import Foundation
import SwiftUI

struct ThemedProfileView: View {
    // User data
    let user: User?
    
    init(user: User? = nil) {
        self.user = user
    }
    
    // We don't need these state variables anymore as we'll use user data
    // but keeping them as fallbacks when user is nil
    @State private var username = "Alex Johnson"
    @State private var email = "alex.johnson@example.com"
    @State private var phoneNumber = "+94 77 123 4567"
    @State private var location = "Colombo, Sri Lanka"
    
    // Settings
    @State private var notificationsEnabled = true
    @State private var locationSharingEnabled = true
    @State private var emergencyContactsEnabled = true
    @State private var biometricsEnabled = true
    
    // View states
    @State private var showEditProfile = false
    @State private var showingLogoutAlert = false
    
    // Theme colors
    private let primaryColor = Color(red: 0.13, green: 0.36, blue: 0.37)
    private let secondaryColor = Color(red: 0.18, green: 0.5, blue: 0.5)
    private let accentColor = Color(red: 0.0, green: 0.7, blue: 0.6)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with profile photo
                    headerView
                    
                    // Profile card
                    profileCard
                    
                    // Settings sections
                    settingsSection(title: "App Settings", settings: [
                        SettingItem(icon: "bell.fill", title: "Notifications", hasToggle: true, isOn: $notificationsEnabled),
                        SettingItem(icon: "location.fill", title: "Location Services", hasToggle: true, isOn: $locationSharingEnabled),
                        SettingItem(icon: "person.2.fill", title: "Emergency Contacts", hasToggle: true, isOn: $emergencyContactsEnabled),
                        SettingItem(icon: "faceid", title: "Biometric Authentication", hasToggle: true, isOn: $biometricsEnabled)
                    ])
                    
                    settingsSection(title: "Account & Support", settings: [
                        SettingItem(icon: "lock.fill", title: "Change Password", action: { print("Change password tapped") }),
                        SettingItem(icon: "shield.fill", title: "Privacy Settings", action: { print("Privacy settings tapped") }),
                        SettingItem(icon: "questionmark.circle.fill", title: "Help Center", action: { print("Help center tapped") }),
                        SettingItem(icon: "exclamationmark.bubble.fill", title: "Report a Problem", action: { print("Report problem tapped") })
                    ])
                    
                    // Logout button
                    logoutButton
                        .padding(.top, 10)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .toolbarBackground(primaryColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(
                    username: $username,
                    email: $email,
                    phoneNumber: $phoneNumber,
                    location: $location,
                    primaryColor: primaryColor
                )
            }
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    // Handle logout here
                    print("User logged out")
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .onAppear {
                // If user data is available, update the state variables
                if let user = user {
                    username = user.username
                    email = user.email
                    phoneNumber = user.phone
                    location = user.location
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(primaryColor)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .padding(.top, 20)
            
            Button("Edit Profile") {
                showEditProfile = true
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(primaryColor)
            .cornerRadius(20)
        }
    }
    
    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Information")
                .font(.headline)
                .foregroundColor(primaryColor)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                // Use user data if available, otherwise fall back to state variables
                infoRow(icon: "person.fill", title: "Name", value: user?.username ?? username)
                
                Divider()
                    .padding(.leading, 48)
                
                infoRow(icon: "envelope.fill", title: "Email", value: user?.email ?? email)
                
                Divider()
                    .padding(.leading, 48)
                
                infoRow(icon: "phone.fill", title: "Phone", value: user?.phone ?? phoneNumber)
                
                Divider()
                    .padding(.leading, 48)
                
                infoRow(icon: "location.fill", title: "Location", value: user?.location ?? location)
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(primaryColor)
                .frame(width: 24, height: 24)
                .padding(.leading, 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
    }
    
    private func settingsSection(title: String, settings: [SettingItem]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(primaryColor)
                .padding(.horizontal, 4)
                .padding(.top, 8)
            
            VStack(spacing: 0) {
                ForEach(Array(settings.enumerated()), id: \.offset) { index, setting in
                    settingRow(setting: setting)
                    
                    if index < settings.count - 1 {
                        Divider()
                            .padding(.leading, 48)
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
    
    private func settingRow(setting: SettingItem) -> some View {
        Button(action: {
            if !setting.hasToggle {
                setting.action?()
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: setting.icon)
                    .font(.system(size: 18))
                    .foregroundColor(primaryColor)
                    .frame(width: 24, height: 24)
                    .padding(.leading, 8)
                
                Text(setting.title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if setting.hasToggle {
                    Toggle("", isOn: setting.isOn ?? .constant(false))
                        .labelsHidden()
                        .tint(accentColor)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(.systemGray3))
                        .padding(.trailing, 8)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var logoutButton: some View {
        Button(action: {
            showingLogoutAlert = true
        }) {
            HStack {
                Spacer()
                
                Text("Log Out")
                    .font(.headline)
                    .foregroundColor(.red)
                
                Spacer()
            }
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Supporting Structures

struct SettingItem {
    let icon: String
    let title: String
    let hasToggle: Bool
    var isOn: Binding<Bool>?
    var action: (() -> Void)?
    
    init(icon: String, title: String, hasToggle: Bool = false, isOn: Binding<Bool>? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.hasToggle = hasToggle
        self.isOn = isOn
        self.action = action
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var username: String
    @Binding var email: String
    @Binding var phoneNumber: String
    @Binding var location: String
    
    let primaryColor: Color
    
    @State private var tempUsername: String = ""
    @State private var tempEmail: String = ""
    @State private var tempPhoneNumber: String = ""
    @State private var tempLocation: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Photo
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(primaryColor)
                        
                        Button("Change Photo") {
                            // Handle photo change
                        }
                        .font(.subheadline)
                        .foregroundColor(primaryColor)
                    }
                    .padding(.top, 20)
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        formField(title: "Name", binding: $tempUsername, icon: "person.fill")
                        formField(title: "Email", binding: $tempEmail, icon: "envelope.fill", keyboardType: .emailAddress)
                        formField(title: "Phone", binding: $tempPhoneNumber, icon: "phone.fill", keyboardType: .phonePad)
                        formField(title: "Location", binding: $tempLocation, icon: "location.fill")
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .principal) {
                    Text("Edit Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(primaryColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                tempUsername = username
                tempEmail = email
                tempPhoneNumber = phoneNumber
                tempLocation = location
            }
        }
    }
    
    private func formField(title: String, binding: Binding<String>, icon: String, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(primaryColor)
                    .frame(width: 24)
                
                TextField("", text: binding)
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    private func saveChanges() {
        username = tempUsername
        email = tempEmail
        phoneNumber = tempPhoneNumber
        location = tempLocation
    }
}

// MARK: - Preview

struct ThemedProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock user for preview
        let mockUser = User(username: "John Doe", email: "john@example.com", phone: "+1 234 567 8900", location: "New York, USA")
        
        return Group {
            ThemedProfileView(user: mockUser)
                .previewDisplayName("With User Data")
                
            ThemedProfileView() // Preview with no user (fallback data)
                .previewDisplayName("No User Data")
        }
    }
}

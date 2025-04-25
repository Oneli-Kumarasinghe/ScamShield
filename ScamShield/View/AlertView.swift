import SwiftUI

struct AlertView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var alertModel = AlertModel()
    @State private var selectedTab: TabType = .home
    
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    // Show content based on selected tab
                    if selectedTab == .profile {
                        ThemedProfileView()
                    } else if selectedTab == .home {
                        alertContent
                    } else if selectedTab == .info {
                        infoContent
                    }
                }

                // Tab Bar
                VStack(spacing: 0) {
                    Divider()
                    HStack {
                        TabIcon(
                            label: "Profile",
                            icon: "person",
                            isSelected: selectedTab == .profile
                        ) {
                            if selectedTab != .profile {
                                dismiss() // Dismiss alert view when switching to profile
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    NotificationCenter.default.post(
                                        name: Notification.Name("SwitchToTab"),
                                        object: nil,
                                        userInfo: ["tab": TabType.profile]
                                    )
                                }
                            }
                        }
                        
                        TabIcon(
                            label: "Home",
                            icon: "house.fill",
                            isSelected: selectedTab == .home
                        ) {
                            if selectedTab != .home {
                                dismiss() // Dismiss alert view
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    NotificationCenter.default.post(
                                        name: Notification.Name("SwitchToTab"),
                                        object: nil,
                                        userInfo: ["tab": TabType.home]
                                    )
                                }
                            }
                        }
                        
                        TabIcon(
                            label: "Info",
                            icon: "info.circle",
                            isSelected: selectedTab == .info
                        ) {
                            if selectedTab != .info {
                                dismiss() // Dismiss alert view
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    NotificationCenter.default.post(
                                        name: Notification.Name("SwitchToTab"),
                                        object: nil,
                                        userInfo: ["tab": TabType.info]
                                    )
                                }
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .background(Color(red: 0.13, green: 0.36, blue: 0.37))
                    .foregroundColor(.white)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Alert Content
    private var alertContent: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Button(action: {
                        dismiss() // Go back to dashboard
                    }) {
                        Image(systemName: "chevron.left")
                    }

                    Spacer()

                    Image(systemName: "bell")
                }
                .foregroundColor(.white)

                Text("Emergency Actions")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text("Choose what you'd like to do")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .background(Color(red: 0.13, green: 0.36, blue: 0.37))
            .cornerRadius(24)
            .padding(.horizontal)

            // Buttons
            ScrollView {
                VStack(spacing: 16) {
                    // Dial Help - Using the working button style from EmergencyActionsView
                    NavigationLink(destination: SriLankaEmergencyDialView()) {
                        HStack {
                            Circle()
                                .fill(Color.teal)
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .semibold))
                                )

                            Text("Dial Help")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                    }

                    // Record - Using the working button style
                    NavigationLink(destination: CallRecordingUploadView()) {
                        HStack {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "mic.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .semibold))
                                )

                            Text("Record")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                    }

                    // Report Only - Using the working button style
                    NavigationLink(destination: ReportingView()) {
                        HStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "exclamationmark.bubble.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .semibold))
                                )

                            Text("Report Only")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 80)
            }
        }
    }

    // MARK: - Info Tab Content
    private var infoContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Information")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                
                Text("This is the information tab where you can find help resources and emergency contacts.")
                    .padding(.horizontal)
                
                // Placeholder content for the Info tab
                VStack(alignment: .leading, spacing: 12) {
                    Text("Help Resources")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    ForEach(1...5, id: \.self) { _ in
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(Color(red: 0.13, green: 0.36, blue: 0.37))
                            Text("Resource Guide")
                                .font(.body)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 4)
                .padding(.horizontal)
                
                Spacer(minLength: 80)
            }
            .padding(.top)
        }
    }
}

// MARK: - TabIcon
/*struct TabIcon: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            .frame(maxWidth: .infinity)
        }
    }
}*/

// MARK: - Preview
struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView()
    }
}

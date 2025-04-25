import SwiftUI

struct EmergencyActionsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                        }

                        Spacer()

                        Image(systemName: "bell")
                            .foregroundColor(.white)
                    }

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

                // Action Buttons
                VStack(spacing: 16) {
                    // Dial Help
                    NavigationLink(destination: SriLankaEmergencyDialView()) {
                        HStack {
                            Circle()
                                .fill(Color.teal)
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20))
                                )

                            Text("Dial Help")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }

                    // Record
                    NavigationLink(destination: CallRecordingUploadView()) {
                        HStack {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "mic.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20))
                                )

                            Text("Record")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }

                    // Report Only
                    NavigationLink(destination: ReportingView()) {
                        HStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "exclamationmark.bubble.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20))
                                )

                            Text("Report Only")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                
                Spacer() // Push content to the top
            }
            .padding(.top)
            .background(Color(.systemGroupedBackground))
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

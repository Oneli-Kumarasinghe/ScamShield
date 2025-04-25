import SwiftUI

// MARK: - Emergency Contact Card
struct EmergencyContactCard: View {
    let contact: EmergencyContact

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(contact.color)
                    .frame(width: 48, height: 48)

                Image(systemName: contact.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.headline)
                Text(contact.number)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "phone.fill")
                .foregroundColor(.green)
                .font(.system(size: 18, weight: .semibold))
                .padding(8)
                .background(Circle().fill(Color.green.opacity(0.1)))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Emergency Dial View
struct SriLankaEmergencyDialView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = EmergencyContactsViewModel()

    @State private var selectedContact: EmergencyContact?
    @State private var showingCallConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    // Custom Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .medium))
                            }

                            Spacer()

                            Image(systemName: "phone.fill")
                                .foregroundColor(.white)
                        }

                        Text("Dial Help")
                            .font(.title2.bold())
                            .foregroundColor(.white)

                        Text("Sri Lanka Emergency Numbers")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    .background(Color(red: 0.13, green: 0.36, blue: 0.37))
                    .cornerRadius(24)
                    .padding(.horizontal)

                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Loading emergency contacts...")
                        Spacer()
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack {
                            Text("Error loading contacts")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button("Retry") {
                                Task {
                                    await viewModel.loadEmergencyContacts()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Tap a contact to start a call")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)

                                ForEach(viewModel.contacts) { contact in
                                    EmergencyContactCard(contact: contact)
                                        .onTapGesture {
                                            selectedContact = contact
                                            showingCallConfirmation = true
                                        }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .alert(isPresented: $showingCallConfirmation) {
                Alert(
                    title: Text("Call \(selectedContact?.name ?? "")"),
                    message: Text(selectedContact?.description ?? ""),
                    primaryButton: .destructive(Text("Call \(selectedContact?.number ?? "")")) {
                        if let number = selectedContact?.number,
                           let url = URL(string: "tel://\(number.replacingOccurrences(of: "-", with: ""))") {
                            UIApplication.shared.open(url)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .task {
                await viewModel.loadEmergencyContacts()
            }
        }
    }
}

struct SriLankaEmergencyDialView_Previews: PreviewProvider {
    static var previews: some View {
        SriLankaEmergencyDialView()
    }
}

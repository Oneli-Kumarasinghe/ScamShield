import SwiftUI
import UniformTypeIdentifiers

// MARK: - CallRecordingUploadView
struct CallRecordingUploadView: View {
    @StateObject private var viewModel = RecordingsViewModel()
    @State private var coordinator: ContextCoordinator?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    // Custom Header (now using viewModel.uiConfig)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            // Back button
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 16) {
                                Button(action: {}) {
                                    Image(systemName: "arrow.up.arrow.down")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.white.opacity(0.2))
                                        .cornerRadius(8)
                                }
                                Button(action: {}) {
                                    Image(systemName: "bell")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .foregroundColor(.white)

                        Text(viewModel.uiConfig.headerTitle)
                            .font(.title2.bold())
                            .foregroundColor(.white)

                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField(viewModel.uiConfig.searchPlaceholder, text: $viewModel.searchText)
                                .foregroundColor(.primary)
                        }
                        .padding(10)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(viewModel.uiConfig.primaryColor)
                    .cornerRadius(24)
                    .padding(.horizontal)

                    // Content
                    ScrollView {
                        VStack(spacing: 16) {
                            if viewModel.filteredRecordings.isEmpty {
                                // Empty state using viewModel.uiConfig
                                VStack(spacing: 20) {
                                    Image(systemName: viewModel.uiConfig.emptyState.iconName)
                                        .font(.system(size: viewModel.uiConfig.emptyState.iconSize))
                                        .foregroundColor(.gray.opacity(0.5))
                                    Text(viewModel.uiConfig.emptyState.title)
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    Text(viewModel.uiConfig.emptyState.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.top, 80)
                            } else {
                                ForEach(viewModel.filteredRecordings) { recording in
                                    CardView {
                                        VStack(alignment: .leading, spacing: 12) {
                                            HStack {
                                                Image(systemName: "waveform")
                                                    .foregroundColor(viewModel.uiConfig.primaryColor)
                                                Text(recording.fileName)
                                                    .font(.headline)
                                                Spacer()
                                                StatusBadge(status: recording.status, uiConfig: viewModel.uiConfig)
                                            }
                                            Divider()
                                            Text("Size: \(viewModel.formattedSize(recording.fileSize)) • \(viewModel.formattedDate(recording.importDate))")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            HStack {
                                                Image(systemName: "text.bubble")
                                                    .foregroundColor(.gray)
                                                    .font(.caption)
                                                TextField(viewModel.uiConfig.addDescriptionPlaceholder, text: Binding(
                                                    get: { recording.description },
                                                    set: { newValue in
                                                        viewModel.updateDescription(for: recording, description: newValue)
                                                    }
                                                ))
                                                .font(.subheadline)
                                            }
                                            .padding(8)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                            HStack(spacing: 12) {
                                                if recording.status != .uploaded {
                                                    Button(action: {
                                                        viewModel.uploadRecording(recording)
                                                    }) {
                                                        HStack {
                                                            Image(systemName: "arrow.up")
                                                            Text(viewModel.uiConfig.uploadButtonText)
                                                        }
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, 10)
                                                        .background(recording.status == .uploading ? Color.gray : viewModel.uiConfig.primaryColor)
                                                        .foregroundColor(.white)
                                                        .cornerRadius(8)
                                                    }
                                                    .disabled(recording.status == .uploading)
                                                }
                                                Button(action: {
                                                    viewModel.removeRecording(recording)
                                                }) {
                                                    HStack {
                                                        Image(systemName: "trash")
                                                        Text(viewModel.uiConfig.removeButtonText)
                                                    }
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 10)
                                                    .background(Color(.systemGray6))
                                                    .foregroundColor(.red)
                                                    .cornerRadius(8)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Button(action: {
                                importFile()
                            }) {
                                HStack {
                                    Image(systemName: "plus")
                                    Text(viewModel.uiConfig.importButtonText)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.uiConfig.primaryColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.vertical)
                        }
                        .padding()
                    }
                }
            }
            .background(viewModel.uiConfig.backgroundColor)
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert(item: Binding<AlertItem?>(
                get: {
                    viewModel.errorMessage.map { AlertItem(message: $0) }
                },
                set: { _ in viewModel.errorMessage = nil }
            )) { alert in
                Alert(
                    title: Text("Error"),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    func importFile() {
        let supportedTypes: [UTType] = [.audio, .mpeg4Audio, .mp3, .wav]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.allowsMultipleSelection = false
        let newCoordinator = ContextCoordinator(manager: viewModel)
        self.coordinator = newCoordinator
        picker.delegate = newCoordinator

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(picker, animated: true)
        }
    }
}

// MARK: - Helper Types

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

// MARK: - Card View
struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: CallRecording.UploadStatus
    let uiConfig: AppUIConfig

    var body: some View {
        Text(status.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(uiConfig.backgroundForStatus(status))
            .foregroundColor(uiConfig.textColorForStatus(status))
            .cornerRadius(8)
    }
}

// MARK: - Updated Context Coordinator
class ContextCoordinator: NSObject, UIDocumentPickerDelegate {
    let manager: RecordingsViewModel

    init(manager: RecordingsViewModel) {
        self.manager = manager
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        manager.importRecording(from: url)
    }
}

struct CallRecordingUploadView_Previews: PreviewProvider {
    static var previews: some View {
        CallRecordingUploadView()
    }
}

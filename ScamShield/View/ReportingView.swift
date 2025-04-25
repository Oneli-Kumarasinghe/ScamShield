import SwiftUI
import UIKit
import Combine

// MARK: - ReportingView
struct ReportingView: View {
    @StateObject private var viewModel = ReportingViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingImagePicker = false
    @FocusState private var focusedField: Field?
    
    enum Field { case phoneNumber, description }

    private var isValidToSubmit: Bool {
        !viewModel.currentReport.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !viewModel.currentReport.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        viewModel.currentReport.evidenceImage != nil // Screenshot is required
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                            }
                            
                            Spacer()
                            
                            
                            
                            // Balance the layout with an invisible element
                            Image(systemName: "chevron.left")
                                .opacity(0)
                        }
                        .foregroundColor(.white)
                        
                        Text("Report a Problem")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text("Help keep everyone safe")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    .background(Color(red: 0.13, green: 0.36, blue: 0.37))
                    .cornerRadius(24)
                    .padding(.horizontal)
                    
                    // Form Content
                    ScrollView {
                        VStack(spacing: 16) {
                            // Phone Number Section
                            ReportFormSection {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Report a Number")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    HStack {
                                        Text("+94")
                                            .foregroundStyle(.secondary)
                                        TextField("Enter phone", text: $viewModel.currentReport.phoneNumber)
                                            .keyboardType(.phonePad)
                                            .focused($focusedField, equals: .phoneNumber)
                                            .padding(.vertical, 8)
                                    }
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .phoneNumber ? Color(red: 0.13, green: 0.36, blue: 0.37) : Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                            
                            // Report Type Section
                            ReportFormSection {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Type of Report")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Menu {
                                        ForEach(viewModel.availableReportTypes) { type in
                                            Button {
                                                viewModel.setReportType(type)
                                            } label: {
                                                Label(type.name, systemImage: type.systemImage)
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: viewModel.currentReport.reportType.systemImage)
                                                .foregroundColor(Color(red: 0.13, green: 0.36, blue: 0.37))
                                                .font(.system(size: 16, weight: .semibold))
                                                .frame(width: 24, height: 24)
                                            
                                            Text(viewModel.currentReport.reportType.name)
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(Color(red: 0.13, green: 0.36, blue: 0.37))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            
                            // Description Section
                            ReportFormSection {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Description")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    ZStack(alignment: .topLeading) {
                                        if viewModel.currentReport.description.isEmpty {
                                            Text("Describe what happened…")
                                                .foregroundStyle(.tertiary)
                                                .padding(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 0))
                                        }
                                        TextEditor(text: $viewModel.currentReport.description)
                                            .focused($focusedField, equals: .description)
                                            .frame(minHeight: 100, maxHeight: 150)
                                            .padding(4)
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .description ? Color(red: 0.13, green: 0.36, blue: 0.37) : Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                            
                            // Evidence Section
                            ReportFormSection {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Evidence (Required)")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        if viewModel.currentReport.evidenceImage == nil {
                                            Text("*")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    
                                    Button {
                                        isShowingImagePicker = true
                                    } label: {
                                        HStack(spacing: 16) {
                                            ZStack {
                                                Circle()
                                                    .fill(viewModel.currentReport.evidenceImage != nil ? Color.teal : Color.orange)
                                                    .frame(width: 48, height: 48)
                                                
                                                Image(systemName: "camera.fill")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 20, weight: .semibold))
                                            }
                                            
                                            Text(viewModel.currentReport.evidenceImage != nil ? "Change Screenshot" : "Add Screenshot")
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
                                    
                                    if let imageData = viewModel.currentReport.evidenceImage,
                                       let uiImage = UIImage(data: imageData) {
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 150)
                                                .cornerRadius(12)
                                            
                                            Button {
                                                viewModel.setEvidenceImage(nil)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.title3)
                                                    .foregroundColor(.white)
                                                    .background(Color.black.opacity(0.6))
                                                    .clipShape(Circle())
                                            }
                                            .padding(8)
                                        }
                                    } else {
                                        Text("Please add a screenshot of the conversation")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.top, 4)
                                    }
                                }
                            }
                            
                            // Submit Button
                            Button {
                                if viewModel.validateForm() {
                                    viewModel.submitReport()
                                        .sink(
                                            receiveCompletion: { _ in },
                                            receiveValue: { _ in }
                                        )
                                        .store(in: &viewModel.cancellables)
                                }
                            } label: {
                                HStack {
                                    if viewModel.isSubmitting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.trailing, 8)
                                    }
                                    
                                    Text("Submit Report")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(isValidToSubmit && !viewModel.isSubmitting ? Color(red: 0.13, green: 0.36, blue: 0.37) : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                            }
                            .disabled(!isValidToSubmit || viewModel.isSubmitting)
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 20) // Reduced bottom padding since tab bar is removed
                            
                            if let error = viewModel.validationError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingImagePicker) {
                SafeImagePicker(image: Binding(
                    get: {
                        if let imageData = viewModel.currentReport.evidenceImage {
                            return UIImage(data: imageData)
                        }
                        return nil
                    },
                    set: { newImage in
                        viewModel.setEvidenceImage(newImage)
                    }
                ))
            }
            .alert("Report Submitted", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") {
                    viewModel.resetForm()
                    dismiss()
                }
            } message: {
                Text("Thank you! Your report helps keep everyone safe.")
            }
            .environmentObject(viewModel)
        }
    }
}

// MARK: - ReportFormSection
struct ReportFormSection<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal)
    }
}


// MARK: - SafeImagePicker (unchanged from your original code)
struct SafeImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: SafeImagePicker

        init(_ parent: SafeImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                // Create a reduced copy to prevent memory issues
                let maxSize: CGFloat = 1200
                let scale = min(maxSize/image.size.width, maxSize/image.size.height)
                let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                
                UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
                image.draw(in: CGRect(origin: .zero, size: newSize))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                parent.image = resizedImage
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Preview
struct ReportingView_Previews: PreviewProvider {
    static var previews: some View {
        ReportingView()
    }
}

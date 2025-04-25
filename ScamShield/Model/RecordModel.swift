import SwiftUI
import Combine
import Foundation

// MARK: - Models

/// Model for Call Recording data
struct CallRecording: Identifiable, Equatable, Codable {
    let id: UUID
    let fileName: String
    let fileURL: URL
    let fileSize: Int64
    let importDate: Date
    var duration: TimeInterval
    var description: String
    var status: UploadStatus

    enum UploadStatus: String, Codable {
        case pending = "Pending"
        case uploading = "Uploading"
        case uploaded = "Uploaded"
        case failed = "Failed"
    }

    init(
        id: UUID = UUID(),
        fileName: String,
        fileURL: URL,
        fileSize: Int64,
        importDate: Date,
        duration: TimeInterval,
        description: String,
        status: UploadStatus
    ) {
        self.id = id
        self.fileName = fileName
        self.fileURL = fileURL
        self.fileSize = fileSize
        self.importDate = importDate
        self.duration = duration
        self.description = description
        self.status = status
    }

    static func == (lhs: CallRecording, rhs: CallRecording) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Model for app UI configuration and styling
struct AppUIConfig {
    // Colors
    let primaryColor: Color
    let backgroundColor: Color
    let cardBackgroundColor: Color
    
    // Tab items
    struct TabItem: Identifiable {
        let id = UUID()
        let title: String
        let iconName: String
        let index: Int
    }
    
    let tabItems: [TabItem]
    
    // Header configuration
    let headerTitle: String
    let searchPlaceholder: String
    
    // Empty state configuration
    struct EmptyStateConfig {
        let iconName: String
        let title: String
        let subtitle: String
        let iconSize: CGFloat
    }
    
    let emptyState: EmptyStateConfig
    
    // Button texts
    let importButtonText: String
    let uploadButtonText: String
    let removeButtonText: String
    let addDescriptionPlaceholder: String
    
    // Status badge configurations
    func backgroundForStatus(_ status: CallRecording.UploadStatus) -> Color {
        switch status {
        case .pending: return Color(.systemGray6)
        case .uploading: return Color.blue.opacity(0.1)
        case .uploaded: return Color.green.opacity(0.1)
        case .failed: return Color.red.opacity(0.1)
        }
    }
    
    func textColorForStatus(_ status: CallRecording.UploadStatus) -> Color {
        switch status {
        case .pending: return Color(.systemGray)
        case .uploading: return Color.blue
        case .uploaded: return Color.green
        case .failed: return Color.red
        }
    }
    
    // Default configuration
    static let standard = AppUIConfig(
        primaryColor: Color(red: 0.13, green: 0.36, blue: 0.37),
        backgroundColor: Color(.systemGroupedBackground),
        cardBackgroundColor: Color(.systemBackground),
        tabItems: [
            TabItem(title: "Profile", iconName: "person", index: 0),
            TabItem(title: "Home", iconName: "house.fill", index: 1),
            TabItem(title: "Chats", iconName: "message", index: 2),
            TabItem(title: "Info", iconName: "info.circle", index: 3)
        ],
        headerTitle: "Call Recordings",
        searchPlaceholder: "Search recordings",
        emptyState: EmptyStateConfig(
            iconName: "waveform",
            title: "No recordings yet",
            subtitle: "Import your first recording to get started",
            iconSize: 60
        ),
        importButtonText: "Import Recording",
        uploadButtonText: "Upload",
        removeButtonText: "Remove",
        addDescriptionPlaceholder: "Add description"
    )
}

// MARK: - API Service

/// Protocol defining the API service interface
protocol RecordingsServiceProtocol {
    func fetchRecordings() -> AnyPublisher<[CallRecording], Error>
    func uploadRecording(_ recording: CallRecording) -> AnyPublisher<CallRecording, Error>
    func deleteRecording(_ id: UUID) -> AnyPublisher<Bool, Error>
    func updateRecordingDescription(_ id: UUID, description: String) -> AnyPublisher<CallRecording, Error>
}

/// API errors
enum RecordingsServiceError: Error {
    case networkError
    case serverError(String)
    case decodingError
    case unauthorized
}

/// Mock implementation for development and testing
class MockRecordingsService: RecordingsServiceProtocol {
    private var mockDelay: TimeInterval = 1.0
    
    func fetchRecordings() -> AnyPublisher<[CallRecording], Error> {
        // Simulate network delay
        return Future<[CallRecording], Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + self.mockDelay) {
                // Return mock data
                promise(.success(self.createMockRecordings()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func uploadRecording(_ recording: CallRecording) -> AnyPublisher<CallRecording, Error> {
        return Future<CallRecording, Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                var updatedRecording = recording
                updatedRecording.status = .uploaded
                promise(.success(updatedRecording))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteRecording(_ id: UUID) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                promise(.success(true))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateRecordingDescription(_ id: UUID, description: String) -> AnyPublisher<CallRecording, Error> {
        return Future<CallRecording, Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // In real impl, would find the recording with this ID
                let updatedRecording = self.createMockRecordings().first!
                var modified = updatedRecording
                modified.description = description
                promise(.success(modified))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Generate mock data
    private func createMockRecordings() -> [CallRecording] {
        return [
            CallRecording(
                fileName: "Weekly Team Meeting.m4a",
                fileURL: URL(fileURLWithPath: "/path/to/recording1.m4a"),
                fileSize: 4_523_091,
                importDate: Date().addingTimeInterval(-86400 * 3),
                duration: 1256.0,
                description: "Weekly sync with the product team discussing roadmap",
                status: .uploaded
            ),
            CallRecording(
                fileName: "Client Interview.m4a",
                fileURL: URL(fileURLWithPath: "/path/to/recording2.m4a"),
                fileSize: 8_125_344,
                importDate: Date().addingTimeInterval(-86400 * 1),
                duration: 2387.0,
                description: "Discussion about new requirements",
                status: .pending
            ),
            CallRecording(
                fileName: "Project Planning.m4a",
                fileURL: URL(fileURLWithPath: "/path/to/recording3.m4a"),
                fileSize: 6_234_112,
                importDate: Date(),
                duration: 1823.0,
                description: "",
                status: .uploading
            )
        ]
    }
}

/// Real API service implementation
class RecordingsAPIService: RecordingsServiceProtocol {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(baseURL: URL = URL(string: "https://api.example.com/v1")!) {
        self.baseURL = baseURL
        self.session = URLSession.shared
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    private var authHeaders: [String: String] {
        // In a real app, you would get these from a secure storage or auth service
        return [
            "Authorization": "Bearer SAMPLE_TOKEN",
            "Content-Type": "application/json"
        ]
    }
    
    func fetchRecordings() -> AnyPublisher<[CallRecording], Error> {
        let url = baseURL.appendingPathComponent("recordings")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        authHeaders.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [CallRecording].self, decoder: decoder)
            .mapError { error -> Error in
                if let urlError = error as? URLError {
                    return RecordingsServiceError.networkError
                } else if error is DecodingError {
                    return RecordingsServiceError.decodingError
                } else {
                    return RecordingsServiceError.serverError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func uploadRecording(_ recording: CallRecording) -> AnyPublisher<CallRecording, Error> {
        let url = baseURL.appendingPathComponent("recordings")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        authHeaders.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        // In a real implementation, you would:
        // 1. First upload the actual audio file
        // 2. Then create the recording metadata entry
        
        do {
            request.httpBody = try encoder.encode(recording)
        } catch {
            return Fail(error: RecordingsServiceError.decodingError).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: CallRecording.self, decoder: decoder)
            .mapError { error -> Error in
                if let urlError = error as? URLError {
                    return RecordingsServiceError.networkError
                } else if error is DecodingError {
                    return RecordingsServiceError.decodingError
                } else {
                    return RecordingsServiceError.serverError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func deleteRecording(_ id: UUID) -> AnyPublisher<Bool, Error> {
        let url = baseURL.appendingPathComponent("recordings/\(id.uuidString)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        authHeaders.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        return session.dataTaskPublisher(for: request)
            .map { _ in true }
            .mapError { error -> Error in
                if let urlError = error as? URLError {
                    return RecordingsServiceError.networkError
                } else {
                    return RecordingsServiceError.serverError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func updateRecordingDescription(_ id: UUID, description: String) -> AnyPublisher<CallRecording, Error> {
        let url = baseURL.appendingPathComponent("recordings/\(id.uuidString)")
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        authHeaders.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        struct UpdatePayload: Codable {
            let description: String
        }
        
        do {
            let payload = UpdatePayload(description: description)
            request.httpBody = try encoder.encode(payload)
        } catch {
            return Fail(error: RecordingsServiceError.decodingError).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: CallRecording.self, decoder: decoder)
            .mapError { error -> Error in
                if let urlError = error as? URLError {
                    return RecordingsServiceError.networkError
                } else if error is DecodingError {
                    return RecordingsServiceError.decodingError
                } else {
                    return RecordingsServiceError.serverError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - ViewModel

/// ViewModel to manage data and business logic for RecordView
class RecordingsViewModel: ObservableObject {
    // Published properties for view binding
    @Published var recordings: [CallRecording] = []
    @Published var searchText: String = ""
    @Published var selectedTab: Int = 1
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // UI Configuration
    let uiConfig = AppUIConfig.standard
    
    // Services
    private let apiService: RecordingsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Filter recordings based on search text
    var filteredRecordings: [CallRecording] {
        if searchText.isEmpty {
            return recordings
        } else {
            return recordings.filter { recording in
                recording.fileName.lowercased().contains(searchText.lowercased()) ||
                recording.description.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    init(apiService: RecordingsServiceProtocol = MockRecordingsService()) {
        self.apiService = apiService
        loadRecordings()
    }
    
    // MARK: - Public Methods
    
    /// Load recordings from API and/or local storage
    func loadRecordings() {
        isLoading = true
        
        // First try to load from API
        apiService.fetchRecordings()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        // Fall back to local storage on error
                        self?.loadFromLocalStorage()
                    }
                },
                receiveValue: { [weak self] recordings in
                    self?.recordings = recordings
                    self?.saveToLocalStorage()
                }
            )
            .store(in: &cancellables)
    }
    
    /// Upload a recording
    func uploadRecording(_ recording: CallRecording) {
        guard let index = recordings.firstIndex(where: { $0.id == recording.id }) else { return }
        
        // Update UI immediately
        recordings[index].status = .uploading
        saveToLocalStorage()
        
        // Then start the actual upload
        apiService.uploadRecording(recording)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        
                        // Revert on failure
                        if let index = self?.recordings.firstIndex(where: { $0.id == recording.id }) {
                            self?.recordings[index].status = .failed
                            self?.saveToLocalStorage()
                        }
                    }
                },
                receiveValue: { [weak self] updatedRecording in
                    // Update with the response from server
                    if let index = self?.recordings.firstIndex(where: { $0.id == updatedRecording.id }) {
                        self?.recordings[index] = updatedRecording
                        self?.saveToLocalStorage()
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    /// Remove a recording
    func removeRecording(_ recording: CallRecording) {
        // Update UI immediately
        recordings.removeAll { $0.id == recording.id }
        saveToLocalStorage()
        
        // Then call the API
        apiService.deleteRecording(recording.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        // Could restore the recording on failure
                    }
                },
                receiveValue: { _ in
                    // API call succeeded, already removed from UI
                }
            )
            .store(in: &cancellables)
    }
    
    /// Update recording description
    func updateDescription(for recording: CallRecording, description: String) {
        guard let index = recordings.firstIndex(where: { $0.id == recording.id }) else { return }
        
        // Update UI immediately
        recordings[index].description = description
        saveToLocalStorage()
        
        // Debounce API calls to avoid too many requests
        let workItem = DispatchWorkItem { [weak self] in
            self?.apiService.updateRecordingDescription(recording.id, description: description)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        if case .failure(let error) = completion {
                            self?.errorMessage = error.localizedDescription
                        }
                    },
                    receiveValue: { _ in
                        // Already updated UI
                    }
                )
                .store(in: &self!.cancellables)
        }
        
        // Cancel previous work item if exists
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    /// Import a new recording
    func importRecording(from url: URL) {
        let fileName = url.lastPathComponent
        let fileManager = FileManager.default
        let fileSize = (try? fileManager.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
        
        let newRecording = CallRecording(
            fileName: fileName,
            fileURL: url,
            fileSize: fileSize,
            importDate: Date(),
            duration: 0.0, // In a real app, you'd analyze the audio file to get its duration
            description: "",
            status: .pending
        )
        
        recordings.append(newRecording)
        saveToLocalStorage()
    }
    
    // MARK: - Helper Methods
    
    /// Format file size for display
    func formattedSize(_ size: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    /// Format date for display
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // MARK: - Local Storage
    
    private func saveToLocalStorage() {
        if let data = try? JSONEncoder().encode(recordings) {
            UserDefaults.standard.set(data, forKey: "CallRecordings")
        }
    }
    
    private func loadFromLocalStorage() {
        if let data = UserDefaults.standard.data(forKey: "CallRecordings"),
           let savedRecordings = try? JSONDecoder().decode([CallRecording].self, from: data) {
            recordings = savedRecordings
        }
    }
}

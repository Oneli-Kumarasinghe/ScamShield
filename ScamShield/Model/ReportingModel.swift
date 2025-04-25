import SwiftUI
import Combine

// MARK: - ReportType Model
struct ReportTypeModel: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    let systemImage: String
    
    static func == (lhs: ReportTypeModel, rhs: ReportTypeModel) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Report Model
struct ReportModel: Identifiable, Codable {
    let id: UUID
    var phoneNumber: String
    var reportType: ReportTypeModel
    var description: String
    var evidenceImage: Data?
    var timestamp: Date
    
    init(id: UUID = UUID(), phoneNumber: String = "", reportType: ReportTypeModel, description: String = "", evidenceImage: Data? = nil) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.reportType = reportType
        self.description = description
        self.evidenceImage = evidenceImage
        self.timestamp = Date()
    }
}

// MARK: - Theme Model
struct ThemeModel {
    let primaryColor: Color
    let shadowColor: Color
    let borderColor: Color
    
    static let standard = ThemeModel(
        primaryColor: Color(red: 0.13, green: 0.36, blue: 0.37),
        shadowColor: Color.black.opacity(0.03),
        borderColor: Color(.systemGray4)
    )
}

// MARK: - ReportingViewModel
class ReportingViewModel: ObservableObject {
    // Published properties for UI state
    @Published var currentReport: ReportModel
    @Published var isSubmitting = false
    @Published var showSuccessAlert = false
    @Published var validationError: String?
    @Published var theme: ThemeModel
    
    // Report types from API
    @Published var availableReportTypes: [ReportTypeModel] = []
    
    // For API integration - now public to be accessible from the View
    var cancellables = Set<AnyCancellable>()
    private let apiService: ReportingAPIServiceProtocol
    
    init(apiService: ReportingAPIServiceProtocol = ReportingAPIService()) {
        self.apiService = apiService
        
        // Default theme
        self.theme = ThemeModel.standard
        
     
        let defaultReportType = ReportTypeModel(id: "harassment", name: "Harassment", systemImage: "exclamationmark.bubble")
        self.currentReport = ReportModel(reportType: defaultReportType)
        
        // Load data from API
        fetchReportTypes()
        fetchTheme()
    }
    
    // MARK: - Public Methods
    
    func fetchReportTypes() {
        apiService.getReportTypes()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("Error fetching report types: \(error)")
                        // Fall back to hardcoded defaults if API fails
                        self?.setDefaultReportTypes()
                    }
                },
                receiveValue: { [weak self] reportTypes in
                    self?.availableReportTypes = reportTypes
                    // Set the current report type to the first one
                    if let firstType = reportTypes.first {
                        self?.currentReport.reportType = firstType
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchTheme() {
        apiService.getTheme()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        // Keep using the default theme
                    }
                },
                receiveValue: { [weak self] theme in
                    self?.theme = theme
                }
            )
            .store(in: &cancellables)
    }
    
    func submitReport() -> AnyPublisher<Bool, Error> {
        isSubmitting = true
        
        return apiService.submitReport(currentReport)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                // Fix: receiveOutput must come before receiveCompletion
                receiveOutput: { [weak self] success in
                    if success {
                        self?.showSuccessAlert = true
                    }
                },
                receiveCompletion: { [weak self] completion in
                    self?.isSubmitting = false
                    if case .failure = completion {
                        // Handle error
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    func validateForm() -> Bool {
        guard !currentReport.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationError = "Phone number is required"
            return false
        }
        
        guard !currentReport.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationError = "Description is required"
            return false
        }
        
        guard currentReport.evidenceImage != nil else {
            validationError = "Screenshot evidence is required"
            return false
        }
        
        validationError = nil
        return true
    }
    
    func resetForm() {
        let reportType = currentReport.reportType
        currentReport = ReportModel(reportType: reportType)
        showSuccessAlert = false
        validationError = nil
    }
    
    func setReportType(_ type: ReportTypeModel) {
        currentReport.reportType = type
    }
    
    func setEvidenceImage(_ uiImage: UIImage?) {
        currentReport.evidenceImage = uiImage?.jpegData(compressionQuality: 0.7)
    }
    
    // MARK: - Private Methods
    
    private func setDefaultReportTypes() {
        // Fallback hardcoded values if API fails
        availableReportTypes = [
            ReportTypeModel(id: "harassment", name: "Harassment", systemImage: "exclamationmark.bubble"),
            ReportTypeModel(id: "spam", name: "Spam", systemImage: "trash"),
            ReportTypeModel(id: "scam", name: "Scam", systemImage: "creditcard"),
            ReportTypeModel(id: "inappropriate", name: "Inappropriate Content", systemImage: "flag"),
            ReportTypeModel(id: "impersonation", name: "Impersonation", systemImage: "person.crop.circle.badge.questionmark"),
            ReportTypeModel(id: "other", name: "Other", systemImage: "ellipsis.circle")
        ]
        
        // Set the current report type to the first one
        if let firstType = availableReportTypes.first {
            currentReport.reportType = firstType
        }
    }
}

// MARK: - API Service Protocol
protocol ReportingAPIServiceProtocol {
    func getReportTypes() -> AnyPublisher<[ReportTypeModel], Error>
    func getTheme() -> AnyPublisher<ThemeModel, Error>
    func submitReport(_ report: ReportModel) -> AnyPublisher<Bool, Error>
}

// MARK: - API Service Implementation
class ReportingAPIService: ReportingAPIServiceProtocol {
    private let baseURL = "https://api.example.com/reporting"
    
    func getReportTypes() -> AnyPublisher<[ReportTypeModel], Error> {
        // In a real implementation, this would make an actual API call
        // For now, we'll return the hardcoded values
        let reportTypes = [
            ReportTypeModel(id: "harassment", name: "Harassment", systemImage: "exclamationmark.bubble"),
            ReportTypeModel(id: "spam", name: "Spam", systemImage: "trash"),
            ReportTypeModel(id: "scam", name: "Scam", systemImage: "creditcard"),
            ReportTypeModel(id: "inappropriate", name: "Inappropriate Content", systemImage: "flag"),
            ReportTypeModel(id: "impersonation", name: "Impersonation", systemImage: "person.crop.circle.badge.questionmark"),
            ReportTypeModel(id: "other", name: "Other", systemImage: "ellipsis.circle")
        ]
        
        return Just(reportTypes)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getTheme() -> AnyPublisher<ThemeModel, Error> {
        // Mock API response
        return Just(ThemeModel.standard)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func submitReport(_ report: ReportModel) -> AnyPublisher<Bool, Error> {
        // In a real implementation, this would submit the report to an API
        // For demo purposes, we'll just simulate a network delay and return success
        return Future<Bool, Error> { promise in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Log the report data (for debugging only)
                print("Submitting report for number: \(report.phoneNumber)")
                print("Report type: \(report.reportType.name)")
                print("Description: \(report.description)")
                print("Has image: \(report.evidenceImage != nil)")
                
                // Simulate success
                promise(.success(true))
            }
        }
        .eraseToAnyPublisher()
    }
}

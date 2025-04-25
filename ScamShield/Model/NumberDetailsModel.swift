import Foundation
import CallKit
import Combine

// MARK: - Existing Model Used by Views (RE-ADDED)
struct PhoneNumberReport: Identifiable {
    let id = UUID()
    let phoneNumber: String
    let reportType: String
    let description: String?
    let reportedDate: Date

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: reportedDate, relativeTo: Date())
    }
}

// MARK: - ViewModel
class NumberDetailsViewModel: ObservableObject {
    @Published var phoneNumber: String
    @Published var timesReported: Int = 0
    @Published var riskScore: Int = 0
    @Published var spamActivities: [SpamActivity] = []
    @Published var reports: [PhoneNumberReport] = []
    @Published var numberInformation: NumberInformation?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
    
    init() {
        self.phoneNumber = ""
    }

    func loadData() {
        loadNumberDetails(for: phoneNumber)
    }

    func loadNumberDetails(for number: String) {
        guard let url = URL(string: "http://169.254.140.32:3000/report/\(number)") else {
            self.errorMessage = "Invalid URL"
            return
        }

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: NumberDetailsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { response in
                self.phoneNumber = response.number
                self.riskScore = response.risk_score
                self.timesReported = response.no_of_times_reported

                // Add fake reports for demo/testing
                self.reports = [
                    PhoneNumberReport(
                        phoneNumber: self.phoneNumber,
                        reportType: "Scam",
                        description: "Tried to trick me into sending money.",
                        reportedDate: Date().addingTimeInterval(-3600)
                    ),
                    PhoneNumberReport(
                        phoneNumber: self.phoneNumber,
                        reportType: "Harassment",
                        description: "Multiple disturbing calls.",
                        reportedDate: Date().addingTimeInterval(-7200)
                    )
                ]

                // Simulate additional data
                self.numberInformation = NumberInformation(location: "Colombo", carrier: "Dialog")
                self.spamActivities = self.generateMockSpamActivity()
            }
            .store(in: &cancellables)
    }
    
    func blockNumber() {
        let cleanedNumber = phoneNumber.filter("0123456789".contains)

        guard let number = Int64(cleanedNumber) else {
            print("Invalid phone number format")
            return
        }

        let sharedDefaults = UserDefaults(suiteName: "group.com.T.scamshield")
        var blockedNumbers = sharedDefaults?.array(forKey: "BlockedNumbers") as? [Int64] ?? []

        if !blockedNumbers.contains(number) {
            blockedNumbers.append(number)
            sharedDefaults?.set(blockedNumbers, forKey: "BlockedNumbers")
            print("Number added to blocked list.")
        } else {
            print("Number already blocked.")
        }

        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "T.ScamShield.MyAppCallDirectory") { error in
            if let error = error {
                print("Error reloading extension: \(error.localizedDescription)")
            } else {
                print("Call directory extension reloaded successfully")
            }
        }
    }


    private func generateMockSpamActivity() -> [SpamActivity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<14).map { offset in
            SpamActivity(date: calendar.date(byAdding: .day, value: -offset, to: today)!, reportCount: Int.random(in: 0...3))
        }.reversed()
    }

}


// MARK: - ViewModel for Report Submission (RE-ADDED)
class ReportFormViewModel: ObservableObject {
    let phoneNumber: String
    @Published var reportType: String = "Spam"
    @Published var description: String = ""
    @Published var errorMessage: String?

    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }

    func submitReport() -> AnyPublisher<Bool, Never> {
        // Simulate submission to backend
        return Just(true)
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}



// MARK: - API Response Struct
struct NumberDetailsResponse: Codable {
    let number: String
    let risk_score: Int
    let no_of_times_reported: Int
}

// MARK: - Supporting Models (if not already defined)
struct SpamActivity {
    let date: Date
    let reportCount: Int
}

struct NumberInformation {
    let location: String
    let carrier: String
}

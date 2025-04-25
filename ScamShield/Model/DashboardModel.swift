import SwiftUI

struct CallLog: Identifiable {
    let id = UUID()
    let number: String
    let reason: String
    let timeAgo: String
    let date: Date
}

class DashboardViewModel: ObservableObject {
    @Published var recentCalls: [CallLog] = []
    
    init() {
       
        self.recentCalls = [
            CallLog(number: "+94 0761598793", reason: "Recruitment Harassment", timeAgo: "2h ago", date: Date()),
            CallLog(number: "+94 9820345678", reason: "Spam Call", timeAgo: "4h ago", date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!),
            CallLog(number: "+94 2025550123", reason: "Scam Attempt", timeAgo: "Yesterday", date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        ]
    }
}

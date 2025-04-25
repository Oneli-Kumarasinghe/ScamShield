import SwiftUI

struct EmergencyAction: Identifiable {
    let id = UUID()
    let iconName: String
    let iconColor: Color
    let backgroundColor: Color
    let title: String
    let destination: AnyView
}

class AlertModel: ObservableObject {
    @Published var emergencyActions: [EmergencyAction] = []

    init() {
        loadMockData()
    }

    func loadMockData() {
        emergencyActions = [
            EmergencyAction(
                iconName: "phone.fill",
                iconColor: .white,
                backgroundColor: .teal,
                title: "Dial Help",
                destination: AnyView(SriLankaEmergencyDialView())
            ),
            EmergencyAction(
                iconName: "mic.circle.fill",
                iconColor: .white,
                backgroundColor: .orange,
                title: "Record",
                destination: AnyView(CallRecordingUploadView())
            ),
            EmergencyAction(
                iconName: "exclamationmark.bubble.fill",
                iconColor: .white,
                backgroundColor: .red,
                title: "Report Only",
                destination: AnyView(ReportingView())
            )
        ]
    }
}

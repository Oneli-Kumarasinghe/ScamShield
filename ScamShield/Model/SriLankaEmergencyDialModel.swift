import SwiftUI
import Foundation

// MARK: - Data Models
struct EmergencyContact: Identifiable, Codable {
    let id: String
    let name: String
    let number: String
    let iconName: String
    let colorHex: String
    let description: String
    
    // Computed property for SwiftUI Color (not included in Codable)
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
    
    // For new contacts being created locally
    init(id: String = UUID().uuidString, name: String, number: String, iconName: String, colorHex: String, description: String) {
        self.id = id
        self.name = name
        self.number = number
        self.iconName = iconName
        self.colorHex = colorHex
        self.description = description
    }
    
    // Convenience initializer with Color instead of hex
    init(id: String = UUID().uuidString, name: String, number: String, iconName: String, color: Color, description: String) {
        self.id = id
        self.name = name
        self.number = number
        self.iconName = iconName
        self.colorHex = color.toHex() ?? "#0000FF"
        self.description = description
    }
}

// MARK: - Emergency Contacts Service
protocol EmergencyContactsService {
    func fetchEmergencyContacts() async throws -> [EmergencyContact]
}

// MARK: - Mock Service for Development and Testing
class MockEmergencyContactsService: EmergencyContactsService {
    func fetchEmergencyContacts() async throws -> [EmergencyContact] {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return EmergencyContactsDataStore.sriLankaContacts
    }
}

// MARK: - API Service for Production
class APIEmergencyContactsService: EmergencyContactsService {
    private let baseURL: URL
    
    init(baseURL: URL = URL(string: "https://your-api-endpoint.com")!) {
        self.baseURL = baseURL
    }
    
    func fetchEmergencyContacts() async throws -> [EmergencyContact] {
        let endpoint = baseURL.appendingPathComponent("emergency-contacts")
        
        let (data, response) = try await URLSession.shared.data(from: endpoint)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([EmergencyContact].self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

// MARK: - Network Errors
enum NetworkError: Error {
    case invalidResponse
    case badRequest
    case serverError
    case decodingError(Error)
}

// MARK: - Emergency Contacts Data Store
struct EmergencyContactsDataStore {
    // Static data for Sri Lanka emergency contacts
    static let sriLankaContacts: [EmergencyContact] = [
        EmergencyContact(
            name: "Police Emergency",
            number: "119",
            iconName: "shield.fill",
            colorHex: "#0A84FF",
            description: "For reporting crimes and emergency police assistance"
        ),
        EmergencyContact(
            name: "Ambulance / Medical",
            number: "1990",
            iconName: "cross.fill",
            colorHex: "#FF3B30",
            description: "Suwa Seriya ambulance service for medical emergencies"
        ),
        EmergencyContact(
            name: "Fire & Rescue",
            number: "110",
            iconName: "flame.fill",
            colorHex: "#FF9500",
            description: "For fire emergencies and rescue operations"
        ),
        EmergencyContact(
            name: "Disaster Management",
            number: "117",
            iconName: "exclamationmark.triangle.fill",
            colorHex: "#FFCC00",
            description: "Disaster Management Centre for natural disasters"
        ),
        EmergencyContact(
            name: "Child Protection",
            number: "1929",
            iconName: "person.fill.badge.plus",
            colorHex: "#34C759",
            description: "National Child Protection Authority hotline"
        ),
        EmergencyContact(
            name: "Women's Helpline",
            number: "1938",
            iconName: "person.2.fill",
            colorHex: "#AF52DE",
            description: "Women's helpline for reporting abuse and getting assistance"
        ),
        EmergencyContact(
            name: "Tourist Police",
            number: "1912",
            iconName: "figure.walk",
            colorHex: "#5AC8FA",
            description: "For tourists requiring police assistance"
        ),
        EmergencyContact(
            name: "Accident Service",
            number: "011-2691111",
            iconName: "car.fill",
            colorHex: "#5856D6",
            description: "National Hospital of Sri Lanka accident service"
        )
    ]
}

// MARK: - ViewModel
class EmergencyContactsViewModel: ObservableObject {
    @Published private(set) var contacts: [EmergencyContact] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let service: EmergencyContactsService
    
    // Dependency injection
    init(service: EmergencyContactsService = MockEmergencyContactsService()) {
        self.service = service
    }
    
    // Load emergency contacts
    @MainActor
    func loadEmergencyContacts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            contacts = try await service.fetchEmergencyContacts()
        } catch {
            errorMessage = "Failed to load emergency contacts: \(error.localizedDescription)"
            contacts = EmergencyContactsDataStore.sriLankaContacts // Fallback to local data
        }
        
        isLoading = false
    }
}

// MARK: - Color Extensions
extension Color {
    // Convert hex string to Color
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    // Convert Color to hex string
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

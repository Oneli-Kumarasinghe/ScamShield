import SwiftUI

struct TabIcon: View {
    var label: String
    var icon: String
    var isSelected: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? .white : .white.opacity(0.8))
        }
    }
}

struct TabIcon_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            TabIcon(label: "Profile", icon: "person")
            TabIcon(label: "Home", icon: "house.fill", isSelected: true)
            TabIcon(label: "Info", icon: "info.circle")
        }
        .padding()
        .background(Color(red: 0.13, green: 0.36, blue: 0.37))
        .previewLayout(.sizeThatFits)
    }
}

import SwiftUI

struct BottomTabBar: View {
    @Binding var selectedTab: String

    var body: some View {
        HStack {
            TabIcon(
                label: "Profile",
                icon: "person",
                isSelected: selectedTab == "Profile", // Checking if this tab is selected
                selectedTab: $selectedTab,
                action: {
                    selectedTab = "Profile" // Set selectedTab to "Profile" when this tab is tapped
                }
            )
            
            TabIcon(
                label: "Home",
                icon: "house.fill",
                isSelected: selectedTab == "Home", // Checking if this tab is selected
                selectedTab: $selectedTab,
                action: {
                    selectedTab = "Home" // Set selectedTab to "Home" when this tab is tapped
                }
            )
            
            TabIcon(
                label: "Info",
                icon: "info.circle",
                isSelected: selectedTab == "Info", // Checking if this tab is selected
                selectedTab: $selectedTab,
                action: {
                    selectedTab = "Info" // Set selectedTab to "Info" when this tab is tapped
                }
            )
        }
        .padding(.vertical)
        .background(Color(red: 0.13, green: 0.36, blue: 0.37))
    }
}

struct BottomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomTabBar(selectedTab: .constant("Home"))
            .previewLayout(.sizeThatFits)
    }
}

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selectedDate: Date = Date()
    @State private var isCalendarVisible = false
    @State private var searchText: String = ""
    @State private var navigateToDetails = false
    @StateObject private var numberDetailsViewModel = NumberDetailsViewModel()
    @State private var showReportingView = false
    @State private var showAlertView = false
    @State private var selectedTab: TabType = .home
    
    let user: User?
        init(user: User? = nil) {
            self.user = user
        }
    
    var filteredCalls: [CallLog] {
        let calendar = Calendar.current
        let dateFilteredCalls =  viewModel.recentCalls.filter {
            calendar.isDate($0.date, inSameDayAs: selectedDate)
        }

        if searchText.isEmpty {
            return dateFilteredCalls
        } else {
            return dateFilteredCalls.filter { $0.number.contains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                VStack(spacing: 0) {
                   
                    if selectedTab == .profile {
                        ThemedProfileView(user: user)
                    } else if selectedTab == .home {
                        homeContent
                    } else if selectedTab == .info {
                        infoContent
                    }
                }

                // MARK: - Fixed Tab Bar
                VStack(spacing: 0) {
                    Divider()
                    HStack {
                        TabIcon(
                            label: "Profile",
                            icon: "person",
                            isSelected: selectedTab == .profile
                        ) {
                            selectedTab = .profile
                        }
                        
                        TabIcon(
                            label: "Home",
                            icon: "house.fill",
                            isSelected: selectedTab == .home
                        ) {
                            selectedTab = .home
                        }
                        
                        TabIcon(
                            label: "Info",
                            icon: "info.circle",
                            isSelected: selectedTab == .info
                        ) {
                            selectedTab = .info
                        }
                    }
                    .padding(.vertical, 12)
                    .background(Color(red: 0.13, green: 0.36, blue: 0.37))
                    .foregroundColor(.white)
                }
            }
            .animation(.easeInOut, value: isCalendarVisible)
            .animation(.easeInOut, value: selectedTab)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showReportingView) {
            ReportingView()
        }
        .sheet(isPresented: $showAlertView) {
            AlertView()
        }
        .onAppear {
            setupNotificationObserver()
        }
    }
    
    // Set up observer for tab change notifications
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("SwitchToTab"),
            object: nil,
            queue: .main
        ) { notification in
            if let tabInfo = notification.userInfo as? [String: Any],
               let tab = tabInfo["tab"] as? TabType {
                selectedTab = tab
            }
        }
    }
    
    // MARK: - Home Tab Content
    private var homeContent: some View {
        VStack(spacing: 0) {
            if isCalendarVisible {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(Color(.systemBackground))
                .transition(.move(edge: .top).combined(with: .opacity))
                .tint(Color(red: 0.13, green: 0.36, blue: 0.37))
            }

            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - Header Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Welcome Back")
                                .font(.title2).bold()
                                .foregroundColor(.white)
                            Spacer()
                            HStack(spacing: 12) {
                                Button(action: {
                                    withAnimation {
                                        isCalendarVisible.toggle()
                                    }
                                }) {
                                    Image(systemName: "calendar")
                                }
                                Image(systemName: "bell")
                            }
                            .foregroundColor(.white)
                        }

                        HStack {
                            Text("Are you facing an emergency?")
                                .foregroundColor(.white)
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                        }

                        HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)

                                    TextField("Search a phone number", text: $searchText)
                                        .foregroundColor(.primary)
                                        .keyboardType(.phonePad)
                                        .submitLabel(.search)

                                    if !searchText.isEmpty {
                                        Button(action: {
                                            searchText = ""
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                    }

                                
                                    Button {
                                        numberDetailsViewModel.loadNumberDetails(for: searchText)
                                        navigateToDetails = true
                                    } label: {
                                        Image(systemName: "arrow.forward.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(.white)
                                .cornerRadius(12)

                                NavigationLink(
                                    destination: NumberDetailsView(viewModel: numberDetailsViewModel),
                                    isActive: $navigateToDetails
                                ) {
                                    EmptyView()
                                }
                    }
                    .padding()
                    .background(Color(red: 0.13, green: 0.36, blue: 0.37))
                    .cornerRadius(24)
                    .padding(.horizontal)

                    // MARK: - Create Report / Alert
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Create your own")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }

                        HStack(spacing: 16) {
                
                            VStack(spacing: 6) {
                                Image(systemName: "doc.text")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("Report")
                                    .font(.footnote)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.13, green: 0.36, blue: 0.37))
                            .cornerRadius(12)
                            .onTapGesture {
                                showReportingView = true
                            }
                            
                            
                            VStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("Alert")
                                    .font(.footnote)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.13, green: 0.36, blue: 0.37))
                            .cornerRadius(12)
                            .onTapGesture {
                                showAlertView = true
                            }
                        }
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 4)
                    .padding(.horizontal)

                    // MARK: - Call History Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Call History: \(formattedDate(selectedDate))")
                            .font(.headline)
                            .padding(.horizontal)

                        if filteredCalls.isEmpty {
                            Text("No reports for this date.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            ForEach(filteredCalls) { call in
                                CallHistoryRow(call: call)
                                    .padding(.horizontal)
                            }
                        }
                    }

                    Spacer(minLength: 80)
                }
            }
        }
    }
    
    // MARK: - Info Tab Content
    private var infoContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Information")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                
                Text("This is the information tab where you can find help resources and emergency contacts.")
                    .padding(.horizontal)
                
                // Placeholder content for the Info tab
                VStack(alignment: .leading, spacing: 12) {
                    Text("Help Resources")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    ForEach(1...5, id: \.self) { _ in
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(Color(red: 0.13, green: 0.36, blue: 0.37))
                            Text("Resource Guide")
                                .font(.body)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 4)
                .padding(.horizontal)
                
                Spacer(minLength: 80)
            }
            .padding(.top)
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func performSearch() {
        print("Searching for: \(searchText)")
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// TabType enum definition
enum TabType {
    case profile
    case home
    case info
}

struct CallHistoryRow: View {
    let call: CallLog

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(call.number)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text("\(call.reason) • \(call.timeAgo)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}

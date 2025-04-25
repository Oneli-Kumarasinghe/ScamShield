import Foundation
import SwiftUI
import Charts
import Combine

// MARK: - Number Details View
struct NumberDetailsView: View {
    @ObservedObject var viewModel: NumberDetailsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showReportSheet = false
    
    private let tealColor = Color(red: 21/255, green: 88/255, blue: 95/255)
    
    var body: some View {
        ZStack {
            // Main content
            ScrollView {
                VStack(spacing: 20) {
                    // Phone number display
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Phone Number")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("", text: $viewModel.phoneNumber)
                            .font(.headline)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray5), lineWidth: 1)
                            )
                            .disabled(true)
                    }
                    
                    // Status cards
                    HStack(spacing: 10) {
                        StatusCard(
                            title: "REPORTED",
                            value: "\(viewModel.timesReported)",
                            subtitle: "Times Reported",
                            backgroundColor: tealColor,
                            foregroundColor: .white
                        )
                        
                        StatusCard(
                            title: "RISK",
                            value: "\(viewModel.riskScore)/100",
                            subtitle: "Risk Score",
                            backgroundColor: tealColor,
                            foregroundColor: .white
                        )
                    }
                    
                    // Activity chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Spam Activity")
                            .font(.headline)
                        
                        Text("Last 14 days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Chart {
                            ForEach(viewModel.spamActivities, id: \.date) { activity in
                                BarMark(
                                    x: .value("Date", activity.date, unit: .day),
                                    y: .value("Reports", activity.reportCount)
                                )
                                .foregroundStyle(tealColor.gradient)
                                .cornerRadius(4)
                            }
                        }
                        .frame(height: 200)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day, count: 2)) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Recent reports section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Reports")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Text("See All")
                                        .font(.subheadline)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                .foregroundColor(tealColor)
                            }
                        }
                        
                        if viewModel.reports.isEmpty {
                            Text("No reports found")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(viewModel.reports) { report in
                                ReportCard(report: report)
                            }
                        }
                    }
                    
                    // Location info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Number Information")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Location")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(viewModel.numberInformation?.location ?? "Unknown")
                                    .font(.subheadline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Carrier")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(viewModel.numberInformation?.carrier ?? "Unknown")
                                    .font(.subheadline)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        Button(action: { viewModel.blockNumber() }) {
                            Text("Block")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                        
                        Button(action: { showReportSheet = true }) {
                            Text("Report")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(tealColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            
           
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: tealColor))
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                    .frame(width: 100, height: 100)
            }
            
            if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text("Error")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        viewModel.loadData()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(tealColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding()
            }
            
            // Block status toast notification
            if viewModel.showBlockStatus, let message = viewModel.blockStatusMessage {
                VStack {
                    Spacer()
                    
                    Text(message)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom))
                        .onAppear {
                            // Auto dismiss after 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    viewModel.showBlockStatus = false
                                }
                            }
                        }
                }
                .animation(.easeInOut, value: viewModel.showBlockStatus)
                .zIndex(2)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Number Details")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {}) {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showReportSheet) {
            ReportFormView(viewModel: ReportFormViewModel(phoneNumber: viewModel.phoneNumber))
        }
        .onAppear {
           viewModel.loadData()
        }
        // Alternative: Alert style notification
        // .alert(isPresented: $viewModel.showBlockStatus, content: {
        //     Alert(
        //         title: Text("Block Status"),
        //         message: Text(viewModel.blockStatusMessage ?? ""),
        //         dismissButton: .default(Text("OK")) {
        //             viewModel.showBlockStatus = false
        //             viewModel.blockStatusMessage = nil
        //         }
        //     )
        // })
    }
}

// MARK: - Updated Report Form View
struct ReportFormView: View {
    @ObservedObject var viewModel: ReportFormViewModel
    @Environment(\.presentationMode) var presentationMode
    
    private let reportTypes = ["Spam", "Scam", "Harassment", "Robocall", "Other"]
    private let tealColor = Color(red: 21/255, green: 88/255, blue: 95/255)
    @State private var isSubmitting = false
    // Storage for cancellables
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Phone Number")) {
                    Text(viewModel.phoneNumber)
                        .font(.headline)
                }
                
                Section(header: Text("Report Type")) {
                    Picker("Report Type", selection: $viewModel.reportType) {
                        ForEach(reportTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Description")) {
                    TextEditor(text: $viewModel.description)
                        .frame(height: 120)
                }
                
                Section {
                    Button(action: submitReport) {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Submit Report")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                    }
                    .disabled(isSubmitting)
                    .listRowBackground(tealColor)
                    .foregroundColor(.white)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Report Number")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Cancel")
                    }
                }
            }
            .disabled(isSubmitting)
        }
    }
    
    func submitReport() {
        isSubmitting = true
        
        viewModel.submitReport()
            .receive(on: DispatchQueue.main)
            .sink { success in
                isSubmitting = false
                if success {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Status Card Component
struct StatusCard: View {
    let title: String
    let value: String
    let subtitle: String
    let backgroundColor: Color
    let foregroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(foregroundColor.opacity(0.8))
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(foregroundColor)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(foregroundColor.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

// MARK: - Report Card Component
struct ReportCard: View {
    let report: PhoneNumberReport
    let tealColor = Color(red: 21/255, green: 88/255, blue: 95/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(report.phoneNumber)
                    .font(.headline)
                Spacer()
                Text(report.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(report.reportType)
                    .font(.subheadline)
                    .foregroundColor(tealColor)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let description = report.description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview
struct NumberDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NumberDetailsView(viewModel: NumberDetailsViewModel(phoneNumber: "+94 753-965-456"))
        }
    }
}

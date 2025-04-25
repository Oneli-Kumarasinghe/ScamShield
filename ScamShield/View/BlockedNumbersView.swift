import SwiftUI

struct BlockedNumbersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var blockedNumbers: [Int64] = []

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                            }

                            Spacer()
                            Image(systemName: "chevron.left").opacity(0)
                        }
                        .foregroundColor(.white)

                        Text("Blocked Numbers")
                            .font(.title2.bold())
                            .foregroundColor(.white)

                        Text("Numbers you’ve blocked from contacting you")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    .background(Color(red: 0.13, green: 0.36, blue: 0.37))
                    .cornerRadius(24)
                    .padding(.horizontal)

                    // List
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(blockedNumbers, id: \.self) { number in
                                BlockedNumberCard(number: number) {
                                    unblock(number: number)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .onAppear(perform: loadBlockedNumbers)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    func loadBlockedNumbers() {
        if let sharedDefaults = UserDefaults(suiteName: "group.com.yourname.ScamShield"),
           let savedNumbers = sharedDefaults.array(forKey: "BlockedNumbers") as? [Int64] {
            blockedNumbers = savedNumbers
        }
    }

    func unblock(number: Int64) {
        if let sharedDefaults = UserDefaults(suiteName: "group.com.yourname.ScamShield") {
            var current = sharedDefaults.array(forKey: "BlockedNumbers") as? [Int64] ?? []
            current.removeAll { $0 == number }
            sharedDefaults.set(current, forKey: "BlockedNumbers")
            blockedNumbers = current
        }
    }
}

struct BlockedNumberCard: View {
    let number: Int64
    let onUnblock: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("+\(number)")
                .font(.headline)
                .foregroundColor(.primary)

            HStack {
                Spacer()
                Button(action: onUnblock) {
                    Text("Unblock")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.7), lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}


struct BlockedNumbersView_Previews: PreviewProvider {
    static var previews: some View {
        BlockedNumbersView()
    }
}

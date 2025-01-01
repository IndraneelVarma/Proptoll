import SwiftUI

struct ReleaseNote: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

struct VersionRelease {
    let version: String
    let isStable: Bool
    let summary: String
    let notes: [ReleaseNote]
}

struct WhatsNewView: View {
    // Example data
    let currentRelease = VersionRelease(
        version: Bundle.main.releaseVersionNumber ?? "X.X",
        isStable: true,
        summary: "We've made your billing and payment experience smarter and simpler! Here's what's new:",
        notes: [
            ReleaseNote(
                title: "Introducing in-app Account",
                description: """
                • Advance Payments: Pay more than your current dues, and the extra money will be stored in your Account for future use.
                • Auto-Debit Feature: Account balance will be automatically used to clear future bills, so you don’t have to worry about missing payments!
                • Add Custom Amounts: Top up your Account anytime and use it for hassle-free transactions later.
                • Transaction History: View a detailed list of all your account transactions in one place.
                """
            ),
            ReleaseNote(
                title: "Better Invoice Structure",
                description: """
                • Organized Bills: Bills are now more structured, making it easier to understand your dues and payments.
                • Advance Payment Support: Pay ahead of time and manage your finances effortlessly.
                """
            ),
            ReleaseNote(
                title: "Upgraded UI",
                description: """
                • A fresh, intuitive design to make navigating bills, wallet, and payments smoother than ever!
                """
            )
        ]
    )
    
    // Track if the user has seen what’s new
    @State private var whatsNewShown: Bool = false
    
    var body: some View {
        ZStack {
            // Main background color
            Color(.mainTheme)
                .ignoresSafeArea()
            
            ScrollView {
                HStack {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 12) {
                            Text("New possibilities")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            HStack {
                                Text(currentRelease.version)
                                    .font(.headline)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.bluePurple.opacity(0.2))
                                    .foregroundColor(.bluePurple)
                                    .cornerRadius(20)
                                
                                if currentRelease.isStable {
                                    Text("Stable Version")
                                        .font(.headline)
                                }
                            }
                        }
                        
                        // Divider
                        HStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 2)
                        }
                        
                        // Summary
                        Text(currentRelease.summary)
                            .font(.custom("Montserrat-Medium", size: 12))
                        
                        // Release Notes Section
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(currentRelease.notes) { note in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(note.title)
                                        .font(.custom("Montserrat-Medium", size: 16))
                                        .foregroundColor(.specialText)
                                    
                                    Text(note.description)
                                        .font(.custom("Montserrat-Normal", size: 14))
                                        .lineLimit(nil)              // Allow unlimited lines
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .onAppear {
                whatsNewShown = true
            }
        }
    }
}

#Preview {
    WhatsNewView()
}

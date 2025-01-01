import SwiftUI

struct ProfileView: View {
    // MARK: - Properties
    
    // State Properties
    @State private var showSheet = false
    @State private var isEditingEmail = false
    @State private var editedEmail = ""
    @State private var showingEmailAlert = false
    @State private var showErrorAlert = false
    @State private var floors = 0
    @State private var units: [(Unit, Owner)] = []
    @State private var currentOwner: Owner?
    
    // StateObjects
    @StateObject private var viewModel2 = EditEmailViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    
    // Managers
    @State private var realmManager = RealmManager.shared
    
    // MARK: - Constants
    
    private let horizontalPadding: CGFloat = 24
    private let verticalSpacing: CGFloat = 16
    private let dividerColor = Color.gray.opacity(0.3)
    private let dividerHeight: CGFloat = 1
    
    // MARK: - Methods
    
    private func loadOwnerFromRealm() {
        if let selectedUnitId = UserDefaults.standard.string(forKey: "selectedUnitId") {
            let owners = realmManager.getAllOwners()
            currentOwner = owners.first { owner in
                owner.unitId == selectedUnitId
            }
        }
    }
    
    // MARK: - View Components
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name")
                .font(.custom("Montserrat-Regular", size: 16))
            Text(currentOwner?.user?.name ?? "")
                .font(.custom("Montserrat-Regular", size: 16))
            customDivider
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalSpacing)
    }
    
    private var mobileNumberSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mobile Number")
                .font(.custom("Montserrat-Regular", size: 16))
            Text(currentOwner?.user?.mobileNumber ?? "")
                .font(.custom("Montserrat-Regular", size: 18))
            customDivider
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalSpacing)
    }
    
    private var emailSection: some View {
        Group {
            // Attempt to fetch the email from Keychain
            if let email = /* UserDefaults.standard.string(forKey: "mainEmail")*/ try? keychain.string(forKey: "mainEmail"),
               !email.isEmpty
            {
                existingEmailView(email: email)
            } else {
                emailUpdatePrompt
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalSpacing)
    }
    
    private func existingEmailView(email: String) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.custom("Montserrat-Regular", size: 16))
                Text(email)
                    .font(.custom("Montserrat-Regular", size: 18))
            }
            Spacer()
            
            Text(networkMonitor.isConnected ? "" : "No Internet Connection!")
                .font(.custom("Montserrat-Regular", size: 16))
                .foregroundStyle(.red)
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("") // Empty text to match "Email" label height
                    .font(.custom("Montserrat-Regular", size: 16))
                Button(action: {
                    editedEmail = email
                    showingEmailAlert = true
                    // Matomo event: user tapped "Edit" for email
                    matomoTracker.track(
                        eventWithCategory: "ProfileView",
                        action: "edit email tapped",
                        url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
                    )
                }) {
                    Text("Edit")
                        .font(.custom("Montserrat-Regular", size: 16))
                        .underline()
                        .tint(.primary)
                }
                .disabled(!networkMonitor.isConnected)
            }
        }
    }
    
    private var emailUpdatePrompt: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.orange.opacity(0.2))
            .frame(height: 80)
            .overlay(
                HStack {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.orange)
                    VStack(alignment: .leading) {
                        Text("Update Email")
                            .font(.custom("Montserrat-SemiBold", size: 16))
                            .foregroundColor(.orange)
                        Text("Stay connected and receive\nimportant updates seamlessly.")
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(2)
                            .font(.custom("Montserrat-Regular", size: 12))
                            .foregroundColor(.orange)
                    }
                    Spacer()
                    Button(action: {
                        showingEmailAlert = true
                        // Matomo event: user tapped "Update" in the prompt
                        matomoTracker.track(
                            eventWithCategory: "ProfileView",
                            action: "prompt update email tapped",
                            url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
                        )
                    }) {
                        Text("Update")
                            .foregroundColor(.orange)
                            .font(.custom("Montserrat-Regular", size: 14))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color.orange, lineWidth: 1)
                            )
                    }
                }
                .padding()
            )
    }
    
    private var additionalInfoSection: some View {
        VStack(alignment: .leading, spacing: verticalSpacing) {
            ForEach(currentOwner?.customProperties ?? [], id: \.self) { prop in
                CustomInfoRow(title: prop.name, value: prop.value)
            }
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Montserrat-Regular", size: 16))
            Text(value)
                .font(.custom("Montserrat-Regular", size: 18))
            customDivider
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalSpacing)
    }
    
    private func CustomInfoRow(title: String, value: CustomValue) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formatTitle(title))
                .font(.custom("Montserrat-Regular", size: 16))
            Text(getDisplayValue(from: value))
                .font(.custom("Montserrat-Regular", size: 18))
            customDivider
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalSpacing)
    }
    
    private var customDivider: some View {
        Rectangle()
            .frame(height: dividerHeight)
            .foregroundColor(dividerColor)
            .padding(.top, 8)
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    // Helper function to convert CustomValue to display string
    private func getDisplayValue(from value: CustomValue) -> String {
        switch value {
        case .string(let str): return str
        case .int(let num): return String(num)
        case .double(let num): return String(format: "%.2f", num)
        case .bool(let bool): return bool ? "Yes" : "No"
        case .date(let date): return dateFormatter.string(from: date)
        case .null: return "-"
        }
    }
    
    // Helper function to format camelCase to Capitalized Spaced
    private func formatTitle(_ string: String) -> String {
        // Handle empty string
        guard !string.isEmpty else { return string }
        
        // Add space before capital letters and trim any leading space
        let spacedString = string.reduce("") { result, char in
            if char.isUppercase && !result.isEmpty {
                return result + " " + String(char)
            }
            return result + String(char)
        }
        
        // Capitalize first letter and return
        return spacedString.capitalized
    }
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.custom("Montserrat-Medium", size: 18))
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                HStack {
                    Spacer()
                    // TopBarView() if needed
                    Spacer()
                }
                
                // If the keychain-based email is empty, show the emailSection (prompt).
                if let email = /* UserDefaults.standard.string(forKey: "mainEmail")*/ try? keychain.string(forKey: "mainEmail"),
                   email.isEmpty
                {
                    emailSection
                }
                
                sectionHeader("User Details")
                
                nameSection
                
                mobileNumberSection
                
                // If the keychain-based email is non-empty, show the existing email + edit UI.
                if let email = /* UserDefaults.standard.string(forKey: "mainEmail")*/ try? keychain.string(forKey: "mainEmail"),
                   !email.isEmpty
                {
                    emailSection
                    customDivider
                        .padding(.horizontal, horizontalPadding)
                }
                
                sectionHeader("Plot Details")
                    .padding(.top)
                
                infoRow(
                    title: "No Of Floors",
                    value: (currentOwner?.noOfFloors ?? 0) == 0
                        ? "G"
                        : "G + \(currentOwner?.noOfFloors ?? 0)"
                )
                
                additionalInfoSection
                
                Spacer()
            }
            .onAppear {
                loadOwnerFromRealm()
                // Matomo event: profile screen appeared
                matomoTracker.track(
                    eventWithCategory: "ProfileView",
                    action: "onAppear",
                    url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
                )
            }
            .navigationTitle("Profile")
            .alert("Update Email", isPresented: $showingEmailAlert) {
                TextField("Enter new email", text: $editedEmail)
                    .foregroundStyle(UIDevice.current.majorIOSVersion <= 17 ? .black : .primary)
                    .onChange(of: editedEmail) { _ in
                        editedEmail = editedEmail.lowercased()
                    }
                Button("Confirm") {
                    if editedEmail.isValidEmail {
                        // Matomo event: user confirmed email update
                        matomoTracker.track(
                            eventWithCategory: "ProfileView",
                            action: "email update confirm",
                            url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
                        )
                        
                        if let owner = RealmManager.shared.getOwner(
                            byUnitId: UserDefaults.standard.string(forKey: "selectedUnitId") ?? ""
                        ) {
                            Task {
                                await viewModel2.updateEmail(newEmail: editedEmail, ownerId: owner.userId)
                            }
                        } else {
                            //print("No owner found for this unit")
                        }
                        showingEmailAlert = false
                    } else {
                        showErrorAlert = true
                        showingEmailAlert = false
                    }
                }
                Button("Cancel", role: .cancel) {
                    showingEmailAlert = false
                    editedEmail = ""
                    // Matomo event: user cancelled email update
                    matomoTracker.track(
                        eventWithCategory: "ProfileView",
                        action: "email update cancelled",
                        url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
                    )
                }
            } message: {
                Text("Please enter your new email address.")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Could not update email. Wrong format.")
            }
        }
        .background(.mainTheme)
    }
}

#Preview {
    ProfileView()
}

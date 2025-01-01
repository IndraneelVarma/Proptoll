import SwiftUI
import RealmSwift

struct UnitsView: View {
    @State private var units: [(Unit, Owner)] = []
    @State private var realmManager = RealmManager.shared
    @State private var selectedUnitId: String?
    @StateObject private var viewModel = AccountViewModel()
    @StateObject private var userDefaultsMonitor = UserDefaultsMonitor()
    @Environment(\.dismiss) private var dismiss
    @Binding var unitNumber: String
    
    var sortedUnits: [(Unit, Owner)] {
        units.sorted { firstPair, secondPair in
            if selectedUnitId == firstPair.0.id { return true }
            if selectedUnitId == secondPair.0.id { return false }
            return firstPair.0.unitNumber < secondPair.0.unitNumber
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Plots")
                    .font(.custom("Montserrat-Bold", size: 22))
                    .padding(.vertical)
                Spacer()
            }
            .padding(.top, 15)
            .padding(.horizontal, 10)
            
            Text("These are the plots linked to your phone number.")
                .font(.custom("Montserrat-Regular", size: 16))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 10)
                .padding(.bottom, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(sortedUnits, id: \.0.id) { unit, owner in
                        UnitCardView(
                            unit: unit,
                            owner: owner,
                            isSelected: selectedUnitId == unit.id
                        )
                        .onTapGesture {
                            handleUnitSelection(unit, owner: owner)
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
            }
            Spacer()
        }
        .background(.onMainTheme)
        .onAppear {
            loadUnitsFromRealm()
            selectedUnitId = userDefaultsMonitor.selectedUnitId
        }
    }
    
    private func loadUnitsFromRealm() {
        let owners = realmManager.getAllOwners()
        units = owners.compactMap { owner in
            guard let unit = realmManager.getUnit(forOwnerId: owner.id) else {
                return nil
            }
            return (unit, owner)
        }
    }
    
    private func handleUnitSelection(_ unit: Unit, owner: Owner) {
        selectedUnitId = unit.id
        unitNumber = unit.unitNumber
        userDefaultsMonitor.updateSelectedUnitId(unit.id)
        UserDefaults.standard.set(unit.unitNumber, forKey: "selectedUnitNumber")
        Task {
            await viewModel.fetchAccounts(jsonQuery: [:])
        }
        matomoTracker.track(eventWithCategory: "unit selection",
                           action: "selected unit: \(unit.unitNumber)",
                           url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
    }
}

struct UnitCardView: View {
    let unit: Unit
    let owner: Owner
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .frame(width: 150, height: 125)
                .foregroundStyle(.mainTheme)
                .overlay {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Plot \(unit.unitNumber)")
                                .font(.custom("Montserrat-Bold", size: 16))
                                .foregroundStyle(.primary)
                        
                            
                            Text("Floors: \(owner.noOfFloors == 0 ? "G" : "G+\(owner.noOfFloors)")")
                                .font(.custom("Montserrat-Regular", size: 13))
                                .foregroundStyle(.primary)
                            
                            
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 15))
                                        .foregroundStyle(.green)
                                        .padding(.trailing, -10)
                                }
                            }
                        }
                        .padding()
                        Spacer()
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(isSelected ? .bluePurple : .primary, lineWidth: isSelected ? 2 : 0.5)
                )
        }
    }
}

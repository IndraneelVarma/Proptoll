import SwiftUI

struct TopBarView: View {
    @State private var unitNumber = UserDefaults.standard.string(forKey: "selectedUnitNumber") ?? "0"
    @State private var unitName = ""
    @State private var showSheet = false
    
    var body: some View {
      //  if UserDefaults.standard.integer(forKey: "ownerCount") > 1 //activate this condition if want to show switcher for only multiple units users
        RoundedRectangle(cornerRadius: 50)
            .fill(.plotBar)
            .frame(width: UIScreen.main.bounds.width * 0.925, height: 30)
            .overlay(
                HStack {
                    Spacer()
                    Text("Plot \(unitNumber)")
                        .foregroundStyle(.specialText)
                        .font(.custom("Montserrat-Medium", size: 16))
                    Text(UserDefaults.standard.string(forKey: "organization") ?? "")
                        .foregroundStyle(.specialText)
                        .font(.custom("Montserrat-Regular", size: 16))
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.specialText)
                    Spacer()
                }
                    .frame(width: 330, alignment: .leading)
            )
            .sheet(isPresented: $showSheet) {
                UnitsView(unitNumber: $unitNumber)
                    .presentationDetents([.fraction(0.5)])
            }
            .padding(EdgeInsets(top: 15, leading: 10, bottom: 10, trailing: 10))
            .onTapGesture {
                showSheet = true
            }
            .onAppear {
                updateUnitInfo()
            }
            .onChange(of: UserDefaults.standard.string(forKey: "selectedUnitNumber")) { _ in
                updateUnitInfo()
            }
    
    }
    
    private func updateUnitInfo() {
        unitNumber = UserDefaults.standard.string(forKey: "selectedUnitNumber") ?? ""
        
      /*  // Alternatively, you could fetch the unit name from Realm if needed
        if let unitId = UserDefaults.standard.string(forKey: "selectedUnitId"),
           let owner = RealmManager.shared.getAllOwners().first(where: { owner in
               return RealmManager.shared.getUnit(forOwnerId: owner.id)?.id == unitId
           }),
           let unit = RealmManager.shared.getUnit(forOwnerId: owner.id) {
            unitName = unit.unitName
        } */
    }
}

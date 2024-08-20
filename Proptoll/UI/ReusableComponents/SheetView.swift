import SwiftUI

struct SheetView: View {
    @StateObject var viewModel = ProfileViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a Plot")
                .font(.title)
                .bold()
                .padding(EdgeInsets(top: 15, leading: 10, bottom: 5, trailing: 0))
            Text("Select your prefered plot from the available \noptions")
                .fixedSize(horizontal: false, vertical: true)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 0))
            RoundedRectangle(cornerRadius: 15)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                .frame(width: 200, height: 150)
                .foregroundStyle(.gray)
                .overlay {
                    VStack(alignment: .leading) {
                        Text("Plot No. \(viewModel.profile.first?.plotNumber ?? "xxxx")")
                            .bold()
                            .foregroundStyle(.white)
                            .padding(.bottom, 2)
                        Text(mainName)
                            .font(.system(size: 15))
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                            .padding(.bottom, 2)
                        Text(mainSociety)
                            .font(.system(size: 13))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding()
                }
                .onTapGesture {
                    dismiss()
                }
        }
        .onAppear() {
            viewModel.fetchProfile(authToken: jwtToken ?? "")
        }
        Spacer()
    }
}

#Preview {
    SheetView()
}

import SwiftUI

struct BillsView: View {
    @State private var showSheet = false
    @State private var showingSettings = false
    @State var x = 1
    @State var y = 10
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(alignment: .center, spacing: 0) {
                    ZStack {
                        Color.gray
                            .frame(height: geometry.safeAreaInsets.top)
                            .ignoresSafeArea(.all)
                        
                        HStack {
                            Image(systemName: "house")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding()
                                .foregroundColor(.white)
                            
                            Text("Bills")
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 375, alignment: .leading)
                    }
                    .background(Color.gray)
                    
                    TopBarView(showSheet: $showSheet)
                    
                    HStack {
                        Text("Total Due")
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        Spacer()
                    }
                    
                    HStack {
                        Text("$ \(100)")
                        Spacer()
                        Button(action: {}) {
                            Text("Pay Now")
                                .foregroundStyle(.white)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(.purple))
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                    
                    Divider()
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    
                    HStack {
                        Text("Bills")
                        Spacer()
                        Menu {
                            ForEach(1...10, id: \.self) { i in
                                Button(action: {
                                    x = (i - 1) * 10 + 1
                                    y = i * 10
                                }) {
                                    Text("\(x)-\(y)")
                                }
                            }
                        } label: {
                            Text("\(x)-\(y)")
                                .foregroundColor(.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                )
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                    
                    ScrollView(showsIndicators: false) {
                        ForEach(x...y, id: \.self) { index in
                            BillsCardView(x: index)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSheet) {
            SheetView().presentationDetents([.fraction(0.4)])
        }
        .fullScreenCover(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
                    .navigationBarItems(leading: Button("Back") {
                        showingSettings = false
                    })
                    .navigationBarTitle("Settings", displayMode: .inline)
            }
        }
    }
}

#Preview {
    BillsView()
}

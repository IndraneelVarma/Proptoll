import SwiftUI

struct ReceiptsCardView: View {
    @State private var isExpanded = false
    var x: Int
    private var tables: [Int]
    
    init(x: Int) {
            self.x = x
            self.tables = (1...10).map { $0 * x }
        }
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Text("\(x)")
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? -180 : 0))
            }
            .frame(height: 40)
            .padding(.horizontal)
            .onTapGesture {
                withAnimation(.snappy){
                    isExpanded.toggle()
                }
            }
            if(isExpanded){
                VStack{
                    ForEach(tables, id: \.self){ table in
                        HStack{
                            Text("\(x) x \(table/x) = \(table)")
                        }
                        .frame(height: 40)
                        .padding(.horizontal)
                    }
                }
                .transition(.move(edge: .bottom))
            }
        }
        .background(.gray)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 4)
        .frame(width: 330)
        
    }
}
#Preview {
    ReceiptsCardView(x: 1)
}

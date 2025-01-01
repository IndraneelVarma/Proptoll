import SwiftUI

struct TransactionCardView: View {
   let transaction: Transaction
   
   private var formattedDate: String {
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
       if let date = dateFormatter.date(from: transaction.createdAt) {
           dateFormatter.dateFormat = "d MMM yyyy, HH:mm"
           return dateFormatter.string(from: date)
       }
       return transaction.createdAt
   }
   
   private var arrowImageName: String {
       switch transaction.transactionType {
       case "Debit": return "arrow.down.backward"
       case "Credit": return "arrow.up.forward"
       default: return "arrow.down"
       }
   }
   
   private var transactionColor: Color {
       switch transaction.transactionType {
       case "Debit": return .alert
       case "Credit": return .billPaid
       default: return .primary
       }
   }
   
   var body: some View {
       VStack(spacing: 0) {
           HStack(spacing: 12) {
               Image(systemName: arrowImageName)
                   .font(.system(size: 16))
                   .foregroundColor(transactionColor)
                   .frame(width: 45, height: 45)
                   .background(
                       Circle()
                        .fill(transactionColor.opacity(0.2))
                   )
               
               VStack(alignment: .leading, spacing: 12) {
                   HStack(alignment: .top) {
                       VStack(alignment: .leading, spacing: 4){
                           Text(transaction.event ?? "")
                               .font(.custom("Montserrat-Regular", size: 16))
                               .foregroundColor(.primary)
                               .lineLimit(2)
                               .multilineTextAlignment(.leading)
                           Text(transaction.description ?? "")
                               .font(.custom("Montserrat-Regular", size: 14))
                               .foregroundColor(.secondary)
                               .lineLimit(2)
                               .multilineTextAlignment(.leading)
                       }
                       
                       Spacer()
                       
                       Text("₹\(Int(transaction.amount))")
                           .font(.custom("Montserrat-Bold", size: 16))
                           .foregroundColor(transactionColor)
                   }
                   
                
                       Text(formattedDate)
                           .font(.custom("Montserrat-Regular", size: 14))
                           .foregroundColor(.primary)
                   
               }
           }
           .padding(16)
       }
       .background(.cards)
       .clipShape(RoundedRectangle(cornerRadius: 12))
       .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
       .padding(.horizontal, 8)
       .padding(.vertical, 6)
   }
}

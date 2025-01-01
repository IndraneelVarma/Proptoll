import SwiftUI

struct ExpenseDetailView: View {
    let expenseData: [ServiceExpense]
    
     var totalExpenses: Double
    
     var totalExpensesPrev: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Year Total")
                    .font(.custom("Montserrat-SemiBold", size: 18))
                    .padding(.horizontal)
                
                HStack(spacing: 4) {
                    Text("₹\(Int(totalExpenses))")
                        .font(.custom("Montserrat-Bold", size: 24))
                    
                    if totalExpenses != totalExpensesPrev && totalExpensesPrev > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: totalExpenses > totalExpensesPrev ? "arrow.up" : "arrow.down")
                                .foregroundColor(totalExpenses > totalExpensesPrev ? .billDue : .billPaid)
                            Text(String(format: "%.2f", abs(((totalExpensesPrev - totalExpenses) / totalExpensesPrev) * 100)) + "%")
                                .foregroundColor(totalExpenses > totalExpensesPrev ? .billDue : .billPaid)
                                .font(.custom("Montserrat-Medium", size: 12))
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.vertical, 8)
            
            ScrollView {
                VStack(spacing: 16) {
                    let sortedExpenses = expenseData.sorted(by: { $0.presentYearAmount > $1.presentYearAmount })
                    ForEach(Array(sortedExpenses.enumerated()), id: \.element.serviceName) { index, expense in
                        VStack(spacing: 0) {
                            HStack {
                                Text("\(index + 1).")
                                    .font(.custom("Montserrat-Medium", size: 14))
                                    .foregroundColor(.primary)
                                    .frame(width: 25, alignment: .leading)
                                
                                HStack(spacing: 4) {
                                    Text(expense.serviceName)
                                        .font(.custom("Montserrat-Medium", size: 14))
                                        .foregroundColor(.primary)
                                    
                                    if expense.presentYearAmount != expense.previousYearAmount && expense.previousYearAmount > 0 {
                                        HStack(spacing: 2) {
                                            Image(systemName: expense.presentYearAmount > expense.previousYearAmount ? "arrow.up" : "arrow.down")
                                                .foregroundColor(expense.presentYearAmount > expense.previousYearAmount ? .billDue : .billPaid)
                                            Text(String(format: "%.2f", abs(((expense.presentYearAmount - expense.previousYearAmount) / expense.previousYearAmount) * 100)) + "%")
                                                .foregroundColor(expense.presentYearAmount > expense.previousYearAmount ? .billDue : .billPaid)
                                                .font(.custom("Montserrat-Medium", size: 12))
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                Text("₹\(Int(expense.presentYearAmount))")
                                    .font(.custom("Montserrat-SemiBold", size: 14))
                            }
                            .padding(.horizontal)
                            
                            if expense.serviceName != sortedExpenses.last?.serviceName {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 1)
                                    .padding(.leading, 25)
                            }
                        }
                    }
                }
                .padding(.bottom)
            }
        }
        .padding(.vertical)
        .background(Color.mainTheme)
    }
}

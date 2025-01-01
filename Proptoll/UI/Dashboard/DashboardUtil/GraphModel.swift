import Foundation

struct Graph: Codable, Hashable, Identifiable {
    let id = UUID()
    let monthlyExpenses: [MonthlyExpense]
    let yearlyExpenses: YearlyExpensesData
}

struct MonthlyExpense: Codable, Hashable {
    let month: String
    let billedAmount: Double
    let paidAmount: Double
    let previousYearBilledAmount: Double
    let service: String
}

struct YearlyExpensesData: Codable, Hashable {
    let presentYearExpenses: Double
    let previousYearExpenses: Double
    let services: [ServiceExpense]
}

struct ServiceExpense: Codable, Hashable {
    let serviceName: String
    let presentYearAmount: Double
    let previousYearAmount: Double
}

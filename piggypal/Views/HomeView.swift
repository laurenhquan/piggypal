//
//  HomeView.swift
//  piggypal
//
//  Created by csuftitan on 11/13/25.
//

import SwiftUI
import Charts

extension TransactionsController {
    func transactions(for period: String) -> [Transaction] {
        let all = transactions

        switch period {
        case "Daily":
            return all.filter { Calendar.current.isDateInToday($0.dateMade ?? Date()) }

        case "Weekly":
            return all.filter {
                guard let date = $0.dateMade else { return false }
                return Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
            }

        case "Monthly":
            return all.filter {
                guard let date = $0.dateMade else { return false }
                return Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
            }

        case "Yearly":
            return all.filter {
                guard let date = $0.dateMade else { return false }
                return Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year)
            }

        default:
            return all
        }
    }

    func totalEarned(for period: String) -> Decimal {
        transactions(for: period)
            .filter { ($0.amount as? Decimal ?? 0) > 0 }
            .reduce(0) { $0 + ($1.amount as? Decimal ?? 0) }
    }

    func totalSpent(for period: String) -> Decimal {
        transactions(for: period)
            .filter { ($0.amount as? Decimal ?? 0) < 0 }
            .reduce(0) { $0 + ($1.amount as? Decimal ?? 0) }
    }

    func currentBalance(for period: String) -> Decimal {
        totalEarned(for: period) + totalSpent(for: period)
    }
}

struct HomeView: View {
    @Binding var selectedTab: String
    @State private var showsWarningAlert = false
    @EnvironmentObject var controller: TransactionsController
    @State private var categories: [String] = ["Home & Utilities", "Transportation", "Groceries", "Health", "Restaurant & Dining", "Shopping & Entertainment"]
    
//  UserDefaults
    @AppStorage("defaultCurrency") private var currency: String = "USD"
    @AppStorage("defaultBudget") private var budget: Double = -1
    @AppStorage("budgetPeriod") private var period: String = "Monthly"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    // MARK: PiggyPal Logo
                    Button {
                        selectedTab = "feed"
                    } label: {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .shadow(color: Color("AccentColor").opacity(0.12), radius: 10, y: 5)
                            .padding()
                    }
                    
                    // MARK: Balance Card
                    VStack {
                        // Title
                        Text("Balance")
                            .font(.subheadline)
                            .foregroundColor(Color("TextColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Current Balance
                        Text(controller.currentBalance(for: period), format: .currency(code: currency))
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color("TextColor"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .allowsTightening(true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.top, .bottom], 5)
                        
                        // Today's Date
                        Text("As of \(Date().formatted(.dateTime.month(.twoDigits).day(.twoDigits).year(.twoDigits)))")
                            .font(.footnote)
                            .foregroundColor(Color("TextColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardColor"))
                            .shadow(color: Color("AccentColor").opacity(0.15), radius: 12, y: 6)
                    )
                    .padding(.trailing)
                }
                
                // MARK: Budget Warning
                if budget > 0, abs(controller.totalSpent(for: period)) > Decimal(budget) {
                    HStack {
                        Spacer()
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                        
                        Text("WARNING: You are over your spending budget!")
                            .font(Font.footnote.bold())
                        
                        Spacer()
                    }
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color("NoteColor"))
                    )
                    .padding(.top, -30)
                    .padding([.leading, .trailing])
                }
                
                // MARK: Spending Analysis Card
                VStack {
                    // Title
                    Text("Spending Analysis")
                        .font(Font.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Category Pie Chart
                    let categoryData: [(category: String, amount: Decimal)] =
                    categories.map { category in
                        let tx = controller.transactions(for: period)
                            .filter { $0.category == category }
                        let amount = abs(controller.getBalance(from: tx))
                        return (category, amount)
                    }
                    .filter { $0.amount > 0 }
                    
                    if !categoryData.isEmpty {
                        let totalAmount = categoryData.reduce(0) { $0 + $1.amount }
                        
                        Chart(categoryData, id: \.category) { item in
                            let percent = (item.amount / totalAmount as NSDecimalNumber) as Decimal
                            
                            SectorMark(
                                angle: .value("Amount", item.amount)
                            )
                            .foregroundStyle(by: .value("Category", item.category))
                            .annotation(position: .overlay) {
                                VStack {
                                    Text(item.category)
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                    
                                    Text(percent, format: .percent.precision(.fractionLength(1))).font(.caption2.bold())
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .frame(height: 250)
                        .padding()
                    } else {
                        Text("No spending this month.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding()
                    }
//                    
                    // Spent vs Earned Graph
                    let spendEarnData: [(type: String, amount: Decimal)] = [
                        ("Spent", controller.totalSpent(for: period)),
                        ("Earned", controller.totalEarned(for: period))
                    ]
                    
                    if !spendEarnData.isEmpty {
                        Chart(spendEarnData, id: \.type) { item in
                            BarMark(
                                x: .value("Amount", item.amount)
                            )
                            .foregroundStyle(by: .value("Type", item.type))
                        }
                        .frame(height: 50, alignment: .center)
                        .padding()
                    }
                    
                    // View Log Button
                    Button("View Log") {
                        selectedTab = "log"
                    }
                    .font(Font.headline)
                    .foregroundColor(Color("TextColor"))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color("Button2Color"))
                            .shadow(color: Color("AccentColor").opacity(0.12), radius: 10, y: 5)
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("CardColor"))
                        .shadow(color: Color("AccentColor").opacity(0.15), radius: 12, y: 6)
                )
                .padding([.leading, .trailing])
                
                Spacer()
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant("home"))
        .environmentObject(TransactionsController.shared)
}

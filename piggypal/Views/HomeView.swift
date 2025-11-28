//
//  HomeView.swift
//  piggypal
//
//  Created by csuftitan on 11/13/25.
//

import SwiftUI
import Charts

struct HomeView: View {
    @Binding var selectedTab: String
    @State private var showsWarningAlert = false
    @EnvironmentObject var controller: TransactionsController
    @State private var categories: [String] = ["Home & Utilities", "Transportation", "Groceries", "Health", "Restaurant & Dining", "Shopping & Entertainment"]
    
    var body: some View {
        let startDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        let endDate = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
        let currentTransactions = controller.transactions
            .filter { tx in
                guard let date = tx.dateMade else { return false }
                return date >= startDate && date <= endDate
            }
        let currentBalance = controller.getBalance(from: currentTransactions)
        let categoryData: [(category: String, amount: Decimal)] =
        categories.map { category in
            let tx = currentTransactions
                .filter { $0.category == category }
            let amount = controller.getBalance(from: tx)
            return (category, amount)
        }
        .filter { $0.amount > 0 }
        
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
                            .padding()
                            .shadow(color: Color("AccentColor").opacity(0.15), radius: 12, y: 6)
                    }
                    
                    // MARK: Balance Card
                    VStack {
                        // Title
                        Text("Balance")
                            .font(.subheadline)
                            .foregroundColor(Color("TextColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Current Balance
                        Text(currentBalance, format: .currency(code: "USD")) // change to update based on transaction database
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color("TextColor"))
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
                if controller.getBalance(from: controller.getAllTransactions()) < 0.0 {
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
                    
                    // Category Pie Chart TODO: does not update, fix
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
                    
                    // Spent vs Earned Graph
                    let spent = currentTransactions.filter { ($0.amount?.decimalValue ?? 0) < 0 }
                    let earned = currentTransactions.filter { ($0.amount?.decimalValue ?? 0) > 0 }
                    let spentTotal = abs(controller.getBalance(from: spent))
                    let earnedTotal = controller.getBalance(from: earned)
                    let spendEarnData: [(type: String, amount: Decimal)] = [
                        ("Spent", spentTotal),
                        ("Earned", earnedTotal)
                    ]
                    
                    Chart(spendEarnData, id: \.type) { item in
                        BarMark(
                            x: .value("Amount", item.amount)
                        )
                        .foregroundStyle(by: .value("Type", item.type))
                    }
                    .frame(height: 50, alignment: .center)
                    .padding()
                    
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

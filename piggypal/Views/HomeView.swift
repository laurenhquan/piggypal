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
        
        ScrollView {
            VStack {
                // Title
                Text("Home")
                    .font(Font.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                HStack {
                    // PiggyPal Logo
                    Button {
                        selectedTab = "feed"
                    } label: {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                    
                    // Balance Card
                    VStack {
                        Text("Balance")
                            .foregroundColor(Color("TextColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(currentBalance, format: .currency(code: "USD")) // change to update based on transaction database
                            .font(Font.largeTitle.bold())
                            .foregroundColor(Color("TextColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.top, .bottom], 5)
                        
                        Text("As of \(Date().formatted(.dateTime.month(.twoDigits).day(.twoDigits).year(.twoDigits)))")
                            .foregroundColor(Color("TextColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color("CardColor"))
                    )
                }
                
                // Budget Warning
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
                    .padding(.top, -20)
                }
                
                // Spending Analysis Card
                VStack {
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
                            x: .value("Type", item.type),
                            y: .value("Amount", item.amount)
                        )
                    }
                    
                    // View Log Button
                    Button("View Log") {
                        selectedTab = "log"
                    }
                    .font(Font.title3.bold())
                    .foregroundColor(Color("TextColor"))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color("Button2Color"))
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color("CardColor"))
                )
                
                Spacer()
            }
            .padding([.leading, .trailing])
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant("home"))
        .environmentObject(TransactionsController.shared)
}

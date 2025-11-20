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
//    @State private var showsOinkAlert = false
    @State private var showsWarningAlert = false
    @EnvironmentObject var controller: TransactionsController
    
    var body: some View {
        VStack {
//          Title
            Text("Home")
                .font(Font.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            HStack {
//              PiggyPal Logo
                Button {
//                    showsOinkAlert = true
                    selectedTab = "feed"
                } label: {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
//                .alert("Oink! Oink!", isPresented: $showsOinkAlert) {
//                    Button("OK", role: .cancel) { }
//                }
                
//              Balance Card
                VStack {
                    Text("Balance")
                        .foregroundColor(Color("TextColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                            
                    let startDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
                    let endDate = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
                    Text(controller.getBalance(from: controller.getPeriodTransactions(startDate: startDate, endDate: endDate)), format: .currency(code: "USD")) // change to update based on transaction database
                        .font(Font.largeTitle.bold())
                        .foregroundColor(Color("TextColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.top, .bottom], 5)
                            
                    Text("As of \(Date().formatted(.dateTime.month(.twoDigits).day(.twoDigits).year(.twoDigits)))")
                        .foregroundColor(Color("TextColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
//                    Button {
//                        selectedTab = "feed"
//                    } label: {
//                        Text("Feed Piggy")
//                            .foregroundColor(Color("TextColor"))
//                            .padding()
//                            .background(
//                                RoundedRectangle(cornerRadius: 15)
//                                    .fill(Color("Button2Color"))
//                            )
//                    }
//                    .padding(.top, 5)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color("CardColor"))
                )
                
//                .onAppear {
//                    if controller.getBalance(from: controller.getAllTransactions()) < 0.0 { // show if balance is less than -budget
//                        showsWarningAlert = true
//                    }
//                }
//                .alert("WARNING: You are over your spending budget!", isPresented: $showsWarningAlert) {
//                    Button("Adjust Budget", role: .none) { selectedTab = "settings" }
//                    Button("OK", role: .cancel) { }
//                }
            }
            
//          Budget Warning
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
            
//          Spending Analysis Card
            VStack {
                Text("Spending Analysis")
                    .font(Font.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
//                let startDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
//                let endDate = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
//                let data = [
//                    (category: "Home & Utilities", spent: controller.getBalance(from: controller.getCategoryTransactions(category: "Home & Utilities", startDate: startDate, endDate: endDate))),
//                    (category: "Transportation", spent: controller.getBalance(from: controller.getCategoryTransactions(category: "Transportation", startDate: startDate, endDate: endDate))),
//                    (category: "Groceries", spent: controller.getBalance(from: controller.getCategoryTransactions(category: "Groceries", startDate: startDate, endDate: endDate))),
//                    (category: "Health", spent: controller.getBalance(from: controller.getCategoryTransactions(category: "Health", startDate: startDate, endDate: endDate))),
//                    (category: "Restaurant & Dining", spent: controller.getBalance(from: controller.getCategoryTransactions(category: "Restaurant & Dining", startDate: startDate, endDate: endDate))),
//                    (category: "Shopping & Entertainment", spent: controller.getBalance(from: controller.getCategoryTransactions(category: "Shopping & Entertainment", startDate: startDate, endDate: endDate)))
//                ]
//                Chart(data, id: \.category) { item in
//                    SectorMark(angle: .value("Amount Spent", abs(item.spent)))
//                        .foregroundStyle(by: .value("Category", item.category))
//                }
//                    .padding()
                
                Text("category color coding? and actual numbers")
                    .padding()
                
                Text("Spent vs Made graph")
                    .padding()
                
                Text("actual numbers")
                    .padding()
                
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

#Preview {
    HomeView(selectedTab: .constant("home"))
        .environmentObject(TransactionsController.shared)
}

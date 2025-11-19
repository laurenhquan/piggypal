//
//  HomeView.swift
//  piggypal
//
//  Created by csuftitan on 11/13/25.
//

import SwiftUI

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
                            
                    Text(controller.getBalance(from: controller.getAllTransactions()), format: .currency(code: "USD")) // change to update based on transaction database
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
                    
                Text("<pie graph, showing how money was spent>")
                    .padding()
                
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

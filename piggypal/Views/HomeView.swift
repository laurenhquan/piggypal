//
//  HomeView.swift
//  piggypal
//
//  Created by csuftitan on 11/13/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: String
    @State private var showsOinkAlert = false
    @State private var showsWarningAlert = false
    @EnvironmentObject var controller: TransactionsController
    
    var body: some View {
        VStack {
//          Title
            Text("Home")
                .font(Font.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
//          Balance Card
            HStack {
                VStack {
                    Text("Balance")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(controller.getBalance(from: controller.getAllTransactions()), format: .currency(code: "USD")) // change to update based on transaction database
                        .font(Font.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.top, .bottom], 5)
                    
                    Text("As of \(Date().formatted(.dateTime.month(.wide).day().year()))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    
                Button {
                    selectedTab = "feed"
                } label: {
                    Image(systemName: "plus.forwardslash.minus")
                        .font(Font.title.bold())
                        .foregroundColor(Color("TextColor"))
                        .padding()
                        .background(
                            Circle()
                                .fill(Color("Button1Color"))
                        )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("CardColor"))
            )
            
            .onAppear {
                if controller.getBalance(from: controller.getAllTransactions()) < 0.0 { // show if balance is less than -budget
                    showsWarningAlert = true
                }
            }
            .alert("WARNING: You are over your spending budget!", isPresented: $showsWarningAlert) {
                Button("Adjust Budget", role: .none) { selectedTab = "settings" }
                Button("OK", role: .cancel) { }
            }
            
//          PiggyPal Logo
            Button {
                showsOinkAlert = true
            } label: {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
            .alert("Oink! Oink!", isPresented: $showsOinkAlert) {
                Button("OK", role: .cancel) { }
            }
            
//          Spending Analysis Card
            VStack {
                Text("Spending Analysis")
                    .font(Font.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                HStack {
                    Text("<pie graph, showing how money was spent>")
                        .padding()
                        
                    VStack {
                        Text("category color coding?")
                    }
                    .padding()
                }
                
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
        .padding()
    }
}

#Preview {
    HomeView(selectedTab: .constant("home"))
        .environmentObject(TransactionsController.shared)
}

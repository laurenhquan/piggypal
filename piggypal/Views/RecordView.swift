//
//  RecordView.swift
//  piggypal
//
//  Created by csuftitan on 11/13/25.
//

import SwiftUI

struct RecordView: View {
    @EnvironmentObject var controller: TransactionsController

    var body: some View {
        // Use controller to access Transaction information from TransactionView
        let transaction_data = controller.getAllTransactions()
        
        NavigationStack {
            ScrollView {
                Grid() {
                    // Transaction History Labels
                    GridRow {
                        Text("Date")
                        Text("Category")
                        Text("Description")
                        Text("Price")
                    }
                    
                    .foregroundColor(Color("TextColor"))
                    .font(.headline)
                    Divider()
                        .frame(height: 2)
                        .overlay(Color.black)
                    
                    // Display No Recorded Transactions if there's no current transactions
                    if transaction_data.count == 0 {
                        Text("No Recorded Transactions")
                            .foregroundColor(Color("TextColor"))
                    }
                    
                    // Access information from each transaction
                    ForEach(transaction_data, id: \.self) { data in
                        let currencyCode = data.currencyUsed ?? ""
                        let amount = data.amount?.doubleValue ?? 0
                        let positive = abs(amount)
                        let category = data.category ?? "N/A"
                        let dateMade = data.dateMade ?? Date()
                        let desc = data.desc ?? "N/A"
                        
                        // Display each entry
                        GridRow {
                            Text(dateMade.formatted(date: .numeric, time: .shortened))
                                .multilineTextAlignment(.center)
                            Text(category)
                                .multilineTextAlignment(.center)
                            Text(desc)
                                .multilineTextAlignment(.center)
                            Text(positive, format: .currency(code: currencyCode))
                                .multilineTextAlignment(.trailing)
                        }
                        .foregroundColor(Color("TextColor"))
                        Divider()
                            .frame(height: 2)
                            .overlay(Color.white)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("CardColor"))
                        .shadow(color: Color("AccentColor").opacity(0.15), radius: 12, y: 6)
                )
                .padding()
                Spacer()
            }
            .navigationTitle("Transaction Log")
        }
    }
}

// KEEP
// Transaction History Icon DOUBLES when DELETED
struct Info: Identifiable {
    let id = UUID()
}

// Displays on Canvas
#Preview {
    RecordView().environmentObject(TransactionsController.shared)
}

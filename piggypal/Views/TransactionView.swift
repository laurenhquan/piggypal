//
//  TransactionPage.swift
//  piggypal
//
//  Created by csuftitan on 11/10/25.
//

import SwiftUI


struct TransactionView: View {
    @Binding var Accounts: [String] //to get account data
    @Binding var currency: String
    
    @State private var selectedAccount: String = ""
    @State private var transactionTitle: String = ""
    @State private var amount: Double = 0.0
    @State private var withdrawal: Bool = true
    
    var body: some View {
        VStack {
            Text("New transaction")
                .font(.headline)
            
            Form{
                Section(header: Text("Account").font(.headline)){
                    Picker("Select Account", selection: $selectedAccount) {
                        ForEach (Accounts, id: \.self) {acc in
                            Text(acc)
                                .tag(acc)
                        }
                    }
                }
                
                Section(header: Text("Transaction").font(.headline)){
                    VStack(alignment: .leading, spacing: 4){
                        TextField("Input transaction description", text: $transactionTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Divider()
                        
                        Picker("Deposit or Withdrawal?", selection: $withdrawal) {
                            Text("Withdrawal")
                                .tag(true)
                            Text("Deposit")
                                .tag(false)
                        }
                    }
                }
                
                Section(header: Text("Amount").font(.headline)){
                    VStack(alignment: .leading, spacing: 4){
                        TextField("Input transaction amount $$$", value: $amount, format: .currency(code: currency))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            
            Spacer()
            
            Button("Submit", systemImage: "plus"){
                //send transaction info to database
                //close page
            }
            .padding(.bottom, 20)
        }
        .background(.white)
    }
}

#Preview {
    @Previewable @State var accs = ["A1", "A2", "A3"]
    @Previewable @State var c = "NTD"
    TransactionView(Accounts: $accs, currency: $c)
}

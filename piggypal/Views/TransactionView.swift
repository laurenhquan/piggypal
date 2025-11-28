//
//  TransactionPage.swift
//  piggypal
//
//  Created by csuftitan on 11/10/25.
//

import SwiftUI
import Foundation

struct TransactionView: View {
    @EnvironmentObject var controller: TransactionsController
    
    //@Binding var Accounts: [String] //to get account data
    @Binding var defaultCode: String
    
    @State private var selectedDate = Date()
    //@State private var selectedAccount: String = ""
    @State private var transactionTitle: String = ""
    @State private var amount: Decimal?
    @State private var currencyCode: String = ""
    @State private var withdrawal: Bool = true
    @State private var codes: [String] = Locale.commonISOCurrencyCodes
    @State private var notValid: Bool = false
    @State private var isValid: Bool = false
    @State private var categories: [String] = ["Home & Utilities", "Transportation", "Groceries", "Health", "Restaurant & Dining", "Shopping & Entertainment"]
    @State private var category: String = "Home & Utilities"
    
    init(defaultCode: Binding<String>) {
        self._defaultCode = defaultCode
        
        // If defaultCode exists in codes, use it; else fallback to first code
        let code = codes.contains(defaultCode.wrappedValue) ? defaultCode.wrappedValue : codes.first ?? ""
            _currencyCode = State(initialValue: code)
    }

    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    //Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        DatePicker(
                            "Enter Date",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color("Button1Color"))
                        )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color("CardColor"))
                    )
                    
                    //Amount TODO: take out currency option
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
                            TextField("Enter amount in ...", value: $amount, format: .currency(code: currencyCode))
                                .keyboardType(.decimalPad)
                                .textFieldStyle(PlainTextFieldStyle())
                                .id(currencyCode)
                            Picker("", selection: $currencyCode) {
                                ForEach (codes, id: \.self) {c in
                                    Text(c)
                                        .tag(c)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("Button1Color"))
                        )
                        
                        Divider()
                        
                        Picker("Deposit or Withdrawal?", selection: $withdrawal) {
                            Text("Withdrawal")
                                .tag(true)
                            Text("Deposit")
                                .tag(false)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color("CardColor"))
                    )
                    
                    //Description TODO: make description box bigger
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("Enter description", text: $transactionTitle)
                            .padding()
                            .textFieldStyle(PlainTextFieldStyle())
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("Button1Color"))
                            )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color("CardColor"))
                    )
                    
                    //Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Picker("Add to...", selection: $category) {
                            ForEach (categories, id: \.self) {c in
                                Text(c)
                                    .tag(c)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color("Button1Color"))
                        )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color("CardColor"))
                    )
                }
                .scrollContentBackground(.hidden)
                .background(Color.white)
                
                HStack {
                    Spacer()
                    
                    Button("Clear", systemImage: "xmark") {
                        //reset form
                        selectedDate = Date()
                        transactionTitle = ""
                        category = "Home & Utilities"
                        amount = nil
                        currencyCode = defaultCode
                        withdrawal = true
                    }
                    .bold()
                    .foregroundColor(Color.red)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("Button2Color"))
                    )
                    
                    Button("Submit", systemImage: "plus"){
                        if amount == nil {
                            notValid = true
                        } else {
                            //send transaction info to database
                            var value: Decimal = amount ?? 0.0
                            if withdrawal {
                                value = value * -1
                            }
                            controller.feedPiggy(amount: value, currencyUsed: currencyCode, dateMade: selectedDate, category: category, desc: transactionTitle)
                            //reset form
                            selectedDate = Date()
                            transactionTitle = ""
                            category = ""
                            amount = nil
                            currencyCode = defaultCode
                            withdrawal = true
                            //notification on submit ""
                            isValid = true
                        }
                    }
                    .bold()
                    .foregroundColor(.black)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("Button2Color"))
                    )
                    .alert("Missing required field: Amount", isPresented: $notValid) {
                        Button("OK", role: .cancel) {}
                    }
                    .alert("Done!", isPresented: $isValid) {
                        Button("OK", role: .cancel) {}
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Feed")
        }
        .background(.white)
    }
}

#Preview {
    //@Previewable @State var accs = ["A1", "A2", "A3"]
    //@Previewable @EnvironmentObject var controller: TransactionsController
    @Previewable @State var c = "USD"
    TransactionView(defaultCode: $c)
        .environmentObject(TransactionsController.shared)
}

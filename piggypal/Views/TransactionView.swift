//
//  TransactionPage.swift
//  piggypal
//
//  Created by csuftitan on 11/10/25.
//

import SwiftUI
import Foundation

struct TransactionView: View {
    //Access data model functions
    @EnvironmentObject var controller: TransactionsController
    
    //Access user settings
    @AppStorage("defaultCurrency") private var currency: String = "USD"
    
    //Form data
    @State private var selectedDate = Date()
    @State private var amountText: String = ""
    @State private var amount: Decimal = 0.0
    @State private var isWithdrawal: Bool = true
    @State private var transactionDesc: String = ""
    @State private var category: String = "Home & Utilities"
    @FocusState private var amountFieldFocused: Bool
    
    //Form validation
    @State private var notValid: Bool = false
    @State private var isValid: Bool = false
    
    //Load data
    @State private var categories: [(name: String, icon: String)] = [
        ("Home & Utilities", "house.fill"),
        ("Transportation", "car.fill"),
        ("Groceries", "cart.fill"),
        ("Health", "heart.fill"),
        ("Restaurant & Dining", "fork.knife"),
        ("Shopping & Entertainment", "bag.fill")
    ]
    
    
    func formatAmount(_ value: String) {
        var result = ""
        var decimalFound = false

        for char in value {
            if char.isNumber {
                result.append(char)
            } else if char == "." && !decimalFound {
                result.append(char)
                decimalFound = true
            }
        }

        // If empty, reset
        guard !result.isEmpty else {
            amountText = ""
            return
        }
        
        let number = Double(result) ?? 0
            
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency   // ← USE CURRENCY CODE HERE
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        if let formatted = formatter.string(from: NSNumber(value: number)) {
            amountText = formatted
        }
        
    }

    
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: Form
                Form {
                    // MARK: Date
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
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color("Button1Color"))
                        )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardColor"))
                    )
                    
                    // MARK: Amount
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("Enter amount in \(currency)", text: $amountText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .focused($amountFieldFocused)
                            .onChange(of: amountFieldFocused) { oldValue, newValue in
                                if !newValue {
                                    formatAmount(amountText)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color("Button1Color"))
                            )
                        
                        Divider()
                        
                        Picker("Deposit or Withdrawal?", selection: $isWithdrawal) {
                            Text("Withdrawal")
                                .tag(true)
                            Text("Deposit")
                                .tag(false)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardColor"))
                    )
                    
                    // MARK: Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("Enter description", text: $transactionDesc)
                            .padding()
                            .textFieldStyle(PlainTextFieldStyle())
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color("Button1Color"))
                            )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardColor"))
                    )
                    
                    // MARK: Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        CategoryGridView(categories: $categories, selectedCategory: $category)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardColor"))
                    )
                }
                .scrollContentBackground(.hidden)
                .background(Color.white)
                
                // MARK: Clear/Submit Buttons
                HStack {
                    Spacer()
                    
                    Button("Clear", systemImage: "xmark") {
                        //reset form
                        selectedDate = Date()
                        transactionDesc = ""
                        category = "Home & Utilities"
                        amountText = ""
                        isWithdrawal = true
                    }
                    .bold()
                    .foregroundColor(Color.red)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color("Button2Color"))
                    )
                    
                    Button("Submit", systemImage: "plus"){
                        if amountText == "" {
                            notValid = true
                        } else {
                            //send transaction info to database
                            let value = amountText.filter { "0123456789.".contains($0) }
                            amount = Decimal(string: value) ?? 0.0
                            if isWithdrawal {
                                amount = amount * -1
                            }
                            controller.feedPiggy(amount: amount, currencyUsed: currency, dateMade: selectedDate, category: category, desc: transactionDesc)
                            //reset form
                            selectedDate = Date()
                            transactionDesc = ""
                            category = "Home & Utilities"
                            amountText = ""
                            isWithdrawal = true
                            isValid = true
                        }
                    }
                    .bold()
                    .foregroundColor(.black)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
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
    TransactionView()
        .environmentObject(TransactionsController.shared)
}

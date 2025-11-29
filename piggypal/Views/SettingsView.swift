//
//  SettingsView.swift
//  piggypal
//
//  Created by csuftitan on 11/13/25.
//

import SwiftUI
import Combine

struct SettingsView: View {
    @EnvironmentObject var controller: TransactionsController

//  AppStorage user settings
    @AppStorage("defaultCurrency") private var currency: String = "USD"
    @AppStorage("defaultBudget") private var budget: Double = 0.0
    @AppStorage("budgetPeriod") private var period: String = "Monthly"
    
    @State private var isCleared: Bool = false

    // Full list of currencies (ISO common set)
    let currencies = Locale.commonISOCurrencyCodes.sorted()

    let budgetPeriods = ["Daily", "Weekly", "Monthly", "Yearly"]

    // Categories with system SF Symbols
    let categories: [(name: String, icon: String)] = [
        ("Home & Utilities", "house.fill"),
        ("Transportation", "car.fill"),
        ("Groceries", "cart.fill"),
        ("Health", "heart.fill"),
        ("Restaurant & Dining", "fork.knife"),
        ("Shopping & Entertainment", "bag.fill")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - Currency Card
                    settingsCard(title: "Default Currency", color: Color("CardColor")) {
                        Picker("Currency", selection: $currency) {
                            ForEach(currencies, id: \.self) { c in
                                Text(c)
                            }
                        }
                        .onChange(of: currency) { oldCurrency, newCurrency in
                            Task {
                                await controller.convertAllTransactions(from: oldCurrency, to: newCurrency)
                                
                                if budget > 0 {
                                    do {
                                        let newBudget = try await controller.convert(amount: Decimal(budget), from: oldCurrency, to: newCurrency)
                                        budget = (newBudget as NSDecimalNumber).doubleValue
                                    } catch {
                                        print("Failed to convert budget: \(error)")
                                    }
                                }
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .tint(Color("TextColor"))
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color("Button1Color"))
                        )
                    }

                    // MARK: - Spending Budget
                    settingsCard(title: "Spending Budget", color: Color("CardColor")) {
                        TextField(budget == 0 ? "Enter amount" : "", value: $budget, format: .number)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color("Button1Color"))
                            )
                    }

                    // MARK: - Budget Period
                    settingsCard(title: "Budget Period", color: Color("CardColor")) {
                        Picker("Period", selection: $period) {
                            ForEach(budgetPeriods, id: \.self) { p in
                                Text(p)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 6)
                    }

                    // MARK: - Default Categories (Icon Grid)
                    settingsCard(title: "Default Categories", color: Color("CardColor")) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                            ForEach(categories, id: \.name) { category in
                                VStack(spacing: 10) {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 32))
                                        .foregroundColor(Color("AccentColor"))

                                    Text(category.name)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color("BackgroundColor"))
                                .cornerRadius(14)
                                .shadow(color: .gray.opacity(0.15), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.top, 6)
                    }

                    // MARK: - Clear Transactions
                    Button {
                        controller.clearAllTransactions()
                        isCleared = true
                    } label: {
                        Text("Clear All Transactions")
                            .font(.headline)
                            .foregroundColor(Color("TextColor"))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("Button2Color"))
                            .cornerRadius(14)
                            .shadow(color: Color("AccentColor").opacity(0.12), radius: 10, y: 5)
                    }
                    .alert("Transactions cleared!", isPresented: $isCleared) {
                        Button("OK", role: .cancel) {}
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Settings")
        }
    }

    // MARK: - Card Component
    @ViewBuilder
    func settingsCard<Content: View>(title: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color("TextColor"))

            content()
        }
        .padding()
        .background(color.opacity(0.9))
        .cornerRadius(16)
        .shadow(color: Color("AccentColor").opacity(0.15), radius: 12, y: 6)
    }
}

#Preview {
    SettingsView()
        .environmentObject(TransactionsController.shared)
}

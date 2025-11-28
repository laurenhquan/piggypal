//
//  SettingsView.swift
//  piggypal
//
//  Created by csuftitan on 11/13/25.
//

import SwiftUI
import Combine

// MARK: - Custom Colors
extension Color {
    static let darkPink = Color(red: 255/255, green: 158/255, blue: 177/255)
    static let hotPink = Color(red: 255/255, green: 117/255, blue: 143/255)
    static let lightPink = Color(red: 255/255, green: 201/255, blue: 212/255)
    static let darkYellow = Color(red: 255/255, green: 207/255, blue: 107/255)
}

class AppSettings: ObservableObject {
    @Published var selectedCurrency: String = "USD"
    @Published var budgetPeriod: String = "Monthly"
    @Published var notificationsEnabled: Bool = false
    @Published var notificationType: String = "Standard"
    @Published var spendingBudget: String = ""
}

struct SettingsView: View {
    @EnvironmentObject var controller: TransactionsController

    @EnvironmentObject var settings: AppSettings

    // Full list of currencies (ISO common set)
    let currencies = Locale.commonISOCurrencyCodes.sorted()

    let budgetPeriods = ["Daily", "Weekly", "Monthly"]
    let notificationOptions = ["Standard", "Custom"]

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
                    settingsCard(title: "Default Currency", color: .lightPink) {
                        Picker("Currency", selection: $settings.selectedCurrency) {
                            ForEach(currencies, id: \.self) { currency in
                                Text(currency)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }

                    // MARK: - Spending Budget
                    settingsCard(title: "Spending Budget", color: .lightPink) {
                        TextField("Enter budget amount", text: .constant(""))
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(14)
                    }

                    // MARK: - Budget Period
                    settingsCard(title: "Budget Period", color: .lightPink) {
                        Picker("Period", selection: $settings.budgetPeriod) {
                            ForEach(budgetPeriods, id: \.self) { period in
                                Text(period)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 6)
                    }

                    // MARK: - Default Categories (Icon Grid)
                    settingsCard(title: "Default Categories", color: .lightPink) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                            ForEach(categories, id: \.name) { category in
                                VStack(spacing: 10) {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 32))
                                        .foregroundColor(.hotPink)

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

                    // MARK: - Clear Data
                    Button {
                        // Clear data logic
                    } label: {
                        Text("Clear All Data")
                            .font(.headline)
                            .foregroundColor(Color("TextColor"))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("Button2Color"))
                            .cornerRadius(14)
                            .shadow(color: Color.hotPink.opacity(0.4), radius: 5)
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
        .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    SettingsView()
        .environmentObject(TransactionsController.shared)
        .environmentObject(AppSettings())
}

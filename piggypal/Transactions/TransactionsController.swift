//
//  TransactionsController.swift
//  piggypal
//
//  Created by csuftitan on 11/17/25.
//

import Foundation
import CoreData
import Combine

enum BudgetPeriod: String, CaseIterable {
    case Daily = "Daily"
    case Weekly = "Weekly"
    case Monthly = "Monthly"
    case Yearly = "Yearly"
}

struct ExchangeRateResponse: Codable {
    let result: String?
    let conversion_rates: [String: Double]?
    let base_code: String?
}

final class TransactionsController: ObservableObject {
    static let shared = TransactionsController()
    
    @Published var transactions: [Transaction] = []
    @Published var lastErrorMessage: String?
    
    let persistentContainer: NSPersistentContainer
    
    private init(inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: "TransactionsModel")
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data store failed to load: \(error.localizedDescription)")
                self.lastErrorMessage = error.localizedDescription
            } else {
                self.updateDB()
            }
        }
    }
    
    // MARK: Save Context
    private func save() {
        guard persistentContainer.viewContext.hasChanges else { return }
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Failed to save the context: \(error.localizedDescription)")
            lastErrorMessage = error.localizedDescription
        }
    }
   
    // MARK: Update Database
    func updateDB() {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateMade", ascending: false)]
        
        do {
            let results = try persistentContainer.viewContext.fetch(request)
            DispatchQueue.main.async {
                self.transactions = results
            }
        } catch {
            print("Failed to fetch transactions: \(error.localizedDescription)")
            lastErrorMessage = error.localizedDescription
        }
    }
    
    // MARK: Feed Piggy / Add Transaction
    func feedPiggy(amount: Decimal,
                   currencyUsed: String,
                   dateMade: Date,
                   category: String,
                   desc: String?) {
        let newTransaction = Transaction(context: persistentContainer.viewContext)
        
        newTransaction.amount = NSDecimalNumber(decimal: amount)
        newTransaction.currencyUsed = currencyUsed
        newTransaction.dateMade = dateMade
        newTransaction.category = category
        newTransaction.desc = desc
        
        save()
        updateDB()
    }
    
    // MARK: Delete Transaction
    func deleteTransaction(transaction: Transaction) {
        persistentContainer.viewContext.delete(transaction)
        save()
        updateDB()
    }
    
    // MARK: Edit Transaction
    func editTransaction(transaction: Transaction,
                         newAmount: Decimal,
                         newCurrencyUsed: String,
                         newDateMade: Date,
                         newCategory: String,
                         newDesc: String?) {
        transaction.amount = NSDecimalNumber(decimal: newAmount)
        transaction.currencyUsed = newCurrencyUsed
        transaction.dateMade = newDateMade
        transaction.category = newCategory
        transaction.desc = newDesc
        
        save()
        updateDB()
    }
    
    // MARK: Clear All Transactions
    func clearAllTransactions() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Transaction.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistentContainer.viewContext.execute(deleteRequest)
            try persistentContainer.viewContext.save()
        } catch {
            print("Failed to clear all transactions: \(error.localizedDescription)")
            lastErrorMessage = error.localizedDescription
        }
        
        updateDB()
    }
    
    // MARK: Get Balance
    func getBalance(from transactions: [Transaction]) -> Decimal {
        return transactions.reduce(0) { $0 + ($1.amount?.decimalValue ?? 0)}
    }

    // MARK: Check Date
    static func isDate(_ date: Date, in period: BudgetPeriod, calendar: Calendar = .current) -> Bool {
        switch period {
        case .Daily:
            return calendar.isDateInToday(date)
            
        case .Weekly:
            let nowWeek = calendar.component(.weekOfYear, from: Date())
            let dateWeek = calendar.component(.weekOfYear, from: date)
            let nowYear = calendar.component(.yearForWeekOfYear, from: Date())
            let dateYear = calendar.component(.yearForWeekOfYear, from: date)
            return nowWeek == dateWeek && nowYear == dateYear
            
        case .Monthly:
            let nowMonth = calendar.component(.month, from: Date())
            let dateMonth = calendar.component(.month, from: date)
            let nowYear = calendar.component(.year, from: Date())
            let dateYear = calendar.component(.year, from: date)
            return nowMonth == dateMonth && nowYear == dateYear
            
        case .Yearly:
            let nowYear = calendar.component(.year, from: Date())
            let dateYear = calendar.component(.year, from: date)
            return nowYear == dateYear
        }
    }
    
    // MARK: API Conversion
    private let apiKey = "d7eac8b4713ba76806c910b7"
    private let baseURL = "https://v6.exchangerate-api.com/v6"

    struct APIError: Error {}

    func fetchExchangeRates(baseCurrency: String) async throws -> [String: Double] {
        let urlString = "\(baseURL)/\(apiKey)/latest/\(baseCurrency)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError()
        }
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ExchangeRateResponse.self, from: data)
        guard let rates = decoded.conversion_rates else { throw APIError() }
        return rates
    }

    func convert(amount: Decimal, from fromCurrency: String, to toCurrency: String) async throws -> Decimal {
        if fromCurrency == toCurrency { return amount }
        let rates = try await fetchExchangeRates(baseCurrency: fromCurrency)
        guard let rate = rates[toCurrency] else { throw APIError() }
        let amt = NSDecimalNumber(decimal: amount)
        let converted = amt.multiplying(by: NSDecimalNumber(value: rate))
        return converted.decimalValue
    }
    
    func convertAllTransactions(from oldCurrency: String, to newCurrency: String) async {
        guard oldCurrency != newCurrency else { return }

        for tx in transactions {
            guard let amt = tx.amount?.decimalValue else { continue }
            do {
                let newAmount = try await convert(amount: amt, from: oldCurrency, to: newCurrency)
                tx.amount = NSDecimalNumber(decimal: newAmount)
                tx.currencyUsed = newCurrency
            } catch {
                print("Error converting transaction: \(error)")
            }
        }

        save()
        updateDB()
    }
}

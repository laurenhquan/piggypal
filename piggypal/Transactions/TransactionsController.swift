//
//  TransactionsController.swift
//  piggypal
//
//  Created by csuftitan on 11/17/25.
//

import Foundation
import CoreData
import Combine

struct ExchangeRateResponse: Codable { let conversion_rates: [String: Double] }

class TransactionsController: ObservableObject {
    static let shared = TransactionsController()
    
    @Published var transactions: [Transaction] = []
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TransactionsModel")
        
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    private init() { updateDB() }
    
    func save() {
        guard persistentContainer.viewContext.hasChanges else { return }
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Failed to save the context: \(error.localizedDescription)")
        }
    }
    
    func updateDB() {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        
        do {
            transactions = try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Failed to fetch transactions: \(error.localizedDescription)")
        }
    }
    
    func getBalance(from transactions: [Transaction]) -> Decimal {
        return transactions.reduce(0) { $0 + ($1.amount?.decimalValue ?? 0)}
    }
    
    func feedPiggy(amount: Decimal, currencyUsed: String, dateMade: Date, category: String, desc: String) {
        let newTransaction = Transaction(context: persistentContainer.viewContext)
        
        newTransaction.amount = NSDecimalNumber(decimal: amount)
        newTransaction.currencyUsed = currencyUsed
        newTransaction.dateMade = dateMade
        newTransaction.category = category
        newTransaction.desc = desc.isEmpty ? nil : desc
        
        save()
        updateDB()
    }
    
    @MainActor
    func convertTransactions(from oldCurrency: String, to newCurrency: String) async {
        guard oldCurrency != newCurrency else { return }

        let apiKey = "d7eac8b4713ba76806c910b7"
        let urlString = "https://v6.exchangerate-api.com/v6/\(apiKey)/latest/\(oldCurrency)"
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)

            guard let conversionRate = decoded.conversion_rates[newCurrency] else {
                print("No conversion rate found for \(newCurrency)")
                return
            }

            for tx in transactions {
                if let amount = tx.amount?.decimalValue {
                    let converted = amount * Decimal(conversionRate)
                    tx.amount = NSDecimalNumber(decimal: converted)
                    tx.currencyUsed = newCurrency
                }
            }

            save()
            updateDB()

        } catch {
            print("Currency conversion failed: \(error.localizedDescription)")
        }
    }
    
    func deleteTransaction(transaction: Transaction) {
        persistentContainer.viewContext.delete(transaction)
        save()
        updateDB()
    }
    
    func editTransaction(transaction: Transaction, newAmount: Decimal, newCurrencyUsed: String, newDateMade: Date, newCategory: String, newDesc: String) {
        transaction.amount = NSDecimalNumber(decimal: newAmount)
        transaction.currencyUsed = newCurrencyUsed
        transaction.dateMade = newDateMade
        transaction.category = newCategory
        transaction.desc = newDesc
        
        save()
        updateDB()
    }
    
    func clearAllTransactions() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Transaction.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistentContainer.viewContext.execute(deleteRequest)
            try persistentContainer.viewContext.save()
        } catch {
            print("Failed to clear all transactions: \(error.localizedDescription)")
        }
        
        updateDB()
    }
}

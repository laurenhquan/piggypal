//
//  TransactionsController.swift
//  piggypal
//
//  Created by csuftitan on 11/17/25.
//

import Foundation
import CoreData
import Combine

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
    
    func getAllTransactions() -> [Transaction] {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to return transactions: \(error.localizedDescription)")
            return []
        }
    }
    
    func getBalance(from transactions: [Transaction]) -> Decimal {
        return transactions.reduce(0) { $0 + ($1.amount?.decimalValue ?? 0) }
    }
    
    func getCategoryTransactions(category: String) -> [Transaction] {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", category)
        
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch category transactions: \(error.localizedDescription)")
            return []
        }
    }
    
    func feedPiggy(amount: Decimal, currencyUsed: String, dateMade: Date, category: String, desc: String) {
        let newTransaction = Transaction(context: persistentContainer.viewContext)
        
        newTransaction.amount = NSDecimalNumber(decimal: amount)
        newTransaction.currencyUsed = currencyUsed
        newTransaction.dateMade = dateMade
        newTransaction.category = category
        newTransaction.desc = desc
        
        save()
        updateDB()
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

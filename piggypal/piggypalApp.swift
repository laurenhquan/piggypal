//
//  piggypalApp.swift
//  piggypal
//
//  Created by csuftitan on 11/6/25.
//

import SwiftUI
import CoreData

@main
struct piggypalApp: App {
    @StateObject private var transactionsController = TransactionsController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, transactionsController.persistentContainer.viewContext)
                .environmentObject(transactionsController)
        }
    }
}

//
//  ContentView.swift
//  piggypal
//
//  Created by csuftitan on 11/6/25.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = "home"

    @EnvironmentObject var transactionsController: TransactionsController

    var body: some View {
        TabView(selection: $selectedTab) {
            
            TransactionView()
                .tabItem {
                    Image(systemName: "carrot")
                    Text("Feed")
                }
                .tag("feed")
            
            RecordView()
                .tabItem {
                    Image(systemName: "book.pages")
                    Text("Log")
                }
                .tag("log")
            
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag("home")
            
            ConversionView()
                .tabItem {
                    Image(systemName: "arrow.left.arrow.right")
                    Text("Convert")
                }
                .tag("convert")
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag("settings")
        }
        .environmentObject(transactionsController)
    }
}

#Preview {
    ContentView()
        .environmentObject(TransactionsController.shared)
}

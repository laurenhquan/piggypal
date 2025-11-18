//
//  ContentView.swift
//  piggypal
//
//  Created by csuftitan on 11/6/25.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = "home"
//    @Environment(\.managedObjectContext) private var viewContext
    // temp test data delete later
    @State var accs = ["A1", "A2", "A3"]
    @State var c = "NTD"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TransactionView(Accounts: $accs, currency: $c)
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
    }
}

#Preview {
    ContentView()
}

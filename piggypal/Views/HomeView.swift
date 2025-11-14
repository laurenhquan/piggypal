//
//  HomeView.swift
//  piggypal
//
//  Created by csuftitan on 11/13/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color(red: 255/255, green: 201/255, blue: 212/255)
                .ignoresSafeArea()
            
            VStack {
                Text("Balance: $0.00") //        change to update based on transaction database
                    .font(Font.largeTitle.bold())
                    .foregroundColor(Color.white)
                    .padding()
                
//                Image("AppIcon")
//                    .scaledToFit()
                
                Text("<image of app icon (when clicked it takes you to transaction page?)>")
                    .foregroundColor(Color.white)
                    .padding()
                
                VStack {
                    Text("Spending Analysis")
                        .font(Font.title2.bold())
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text("<pie graph, showing how money was spent>")
                            .foregroundColor(Color.white)
                        
                        VStack {
                            Text("<status graph, showing how much of budget was used>")
                                .foregroundColor(Color.white)
                            Text("if over budget, show warning")
                                .font(Font.footnote)
                                .foregroundColor(Color.white)
                            Text("Warning: You're over your set budget by $X!")
                                .font(Font.footnote)
                                .foregroundColor(Color.red)
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
    }
}

#Preview {
    HomeView()
}

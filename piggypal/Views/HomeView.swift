//
//  HomeView.swift
//  piggypal
//
//  Created by csuftitan on 11/13/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: String
    
    var body: some View {
        VStack {
            Text("Home")
                .font(Font.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            HStack {
                VStack {
                    Text("Balance")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text("$") // change to update based on default currency in settings
                            .font(Font.largeTitle.bold())
                            .frame(maxWidth: 25, alignment: .leading)
                        
                        Text("0.00") // change to update based on transaction database
                            .font(Font.largeTitle.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding([.top, .bottom], 5)
                    
                    Text("As of \(Date().formatted(.dateTime.month(.wide).day().year()))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                }
                    
                Button {
                    selectedTab = "feed"
                } label: {
                    Image(systemName: "plus.forwardslash.minus")
                        .font(Font.title.bold())
                        .foregroundColor(Color.black)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color(red: 255/255, green: 158/255, blue: 177/255))
                        )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(red: 255/255, green: 201/255, blue: 212/255))
            )
                
//           Image("AppIcon")
//              .scaledToFit()
                
            Text("<image of app icon (when clicked it takes you to transaction page?)>")
                .padding()
                
            VStack {
                Text("Spending Analysis")
                    .font(Font.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                HStack {
                    Text("<pie graph, showing how money was spent>")
                        
                    VStack {
                        Text("<status graph, showing how much of budget was used>")
                        Text("if over budget, show warning")
                            .font(Font.footnote)
                        Text("Warning: You're over your set budget by $X!")
                            .font(Font.footnote)
                            .foregroundColor(Color.red)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(red: 255/255, green: 201/255, blue: 212/255))
            )
        }
        .padding()
    }
}


#Preview {
    HomeView(selectedTab: .constant("home"))
}

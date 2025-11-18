//
//  HomeView.swift
//  piggypal
//
//  Created by csuftitan on 11/13/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: String
    @State private var showsAlert = false
    
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
                        .foregroundColor(Color("TextColor"))
                        .padding()
                        .background(
                            Circle()
                                .fill(Color("Button1Color"))
                        )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("CardColor"))
            )
                
            Button {
                showsAlert = true
            } label: {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
            .alert("Oink! Oink!", isPresented: $showsAlert) {
                Button("OK", role: .cancel) { }
            }
            
                
            VStack {
                Text("Spending Analysis")
                    .font(Font.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                HStack {
                    Text("<pie graph, showing how money was spent>")
                        .padding()
                        
                    VStack {
                        Text("<status graph, showing how much of budget was used>")
                        Text("if over budget, show warning")
                            .font(Font.footnote)
                        Text("Warning: You're over your set budget by $X!")
                            .font(Font.footnote)
                            .foregroundColor(Color.red)
                    }
                    .padding()
                }
                
                Button("View Log") {
                    selectedTab = "log"
                }
                .font(Font.title3.bold())
                .foregroundColor(Color("TextColor"))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color("Button2Color"))
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("CardColor"))
            )
            
            Spacer()
        }
        .padding()
    }
}


#Preview {
    HomeView(selectedTab: .constant("home"))
}

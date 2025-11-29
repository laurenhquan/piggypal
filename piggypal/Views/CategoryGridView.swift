//
//  CategoryGridView.swift
//  piggypal
//
//  Created by csuftitan on 11/28/25.
//

import SwiftUI

struct CategoryGridView: View {
    @Binding var categories: [(name: String, icon: String)]
    @Binding var selectedCategory: String

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
            ForEach(categories, id: \.name) { category in
                VStack(spacing: 10) {
                    Image(systemName: category.icon)
                        .font(.system(size: 32))
                        .foregroundColor(Color("AccentColor"))

                    Text(category.name)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(selectedCategory == category.name ? Color("Button2Color") : Color.white)
                )
                .onTapGesture {
                    selectedCategory = category.name
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    @Previewable @State var cs: [(name: String, icon: String)] = [
        ("Home & Utilities", "house.fill"),
        ("Transportation", "car.fill"),
        ("Groceries", "cart.fill"),
        ("Health", "heart.fill"),
        ("Restaurant & Dining", "fork.knife"),
        ("Shopping & Entertainment", "bag.fill")
    ]
    @Previewable @State var c: String = "Home & Utilities"
    CategoryGridView(categories: $cs, selectedCategory: $c)
}

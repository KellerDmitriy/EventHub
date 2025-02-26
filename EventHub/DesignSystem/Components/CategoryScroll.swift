//
//  CategoryScroll.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 20.11.2024.
//

import SwiftUI

struct CategoryScroll: View {
    let categories: [CategoryUIModel]
    let onCategorySelected: (CategoryUIModel) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if categories.isEmpty {
                    ForEach(1..<5) { _ in
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.appBackground)
                                .frame(width: 100, height: 40)
                           
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.appRed)
                                .frame(width: 100, height: 40)
                                .shimmering()
                        }
                    }
                } else {
                    ForEach(categories) { category in
                        CategoryButton(
                            categoryName: category.category.name.localized,
                            imageName: category.image,
                            backgroundColor: category.color,
                            onTap: {
                                onCategorySelected(category)
                            }
                        )
                        .background(category.color) 
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .zIndex(1)
                    }
                    .clipped()
                }
            }
            .padding(.leading, 24)
        }
    }
    
}

#Preview {
    CategoryScroll(categories: [], onCategorySelected: {_ in })
}

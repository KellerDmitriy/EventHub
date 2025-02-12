//
//  DetailView.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 12.02.2025.
//


import SwiftUI

struct DetailViewTest: View {
    @State private var scrollOffset: CGFloat = 0
    private let headerHeight: CGFloat = 300
    private let minHeaderHeight: CGFloat = 100

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    GeometryReader { headerGeometry in
                        let minY = headerGeometry.frame(in: .global).minY
                        let height = max(headerHeight - minY, minHeaderHeight)
                        Image("avatar")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: height)
                            .clipped()
                            .overlay(
                                VStack(alignment: .leading) {
                                    Text("Название трека")
                                        .font(.title)
                                        .bold()
                                    Text("Исполнитель")
                                        .font(.subheadline)
                                }
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .foregroundColor(.white)
                                .offset(y: minY > 0 ? 0 : -minY),
                                alignment: .bottomLeading
                            )
                            .offset(y: minY > 0 ? -minY : 0)
                    }
                    .frame(height: headerHeight)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Информация о треке")
                            .font(.headline)
                        Text("Детали трека и другая информация...")
                        // Добавьте остальной контент здесь
                    }
                    .padding()
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

#Preview {
    DetailViewTest()
}

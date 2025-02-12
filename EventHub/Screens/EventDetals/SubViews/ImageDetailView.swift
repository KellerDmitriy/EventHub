//
//  ImageDetailView.swift
//  EventHub
//
//  Created by Даниил Сивожелезов on 30.11.2024.
//

import SwiftUI
import Kingfisher

struct ImageDetailView: View {
    let imageUrl: String?
    @Binding var isPresented: Bool
    
    var body: some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .global).minY
            ZStack(alignment: .bottomTrailing) {
                if let imageUrl = imageUrl,
                   let url = URL(string: imageUrl) {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 400 + (minY > 0 ? minY : 0))
                        .frame(width: proxy.size.width)
                        .overlay(Color.black.opacity(0.3))
                } else {
                    Image(.cardImg1)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 400 + (minY > 0 ? minY : 0))
                        .frame(width: proxy.size.width)
                        .overlay(Color.black.opacity(0.3))
                }
                
                Button {
                    isPresented = true
                } label: {
                    Image(.share)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 24, maxHeight: 24)
                        .padding(6)
                        .background(.white.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.trailing, 16)
                .padding(.bottom, 250)
            }
        }
       
    }
}

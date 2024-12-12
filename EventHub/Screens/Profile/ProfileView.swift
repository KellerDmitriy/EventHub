//
//  ProfileView.swift
//  EventHub
//
//  Created by Руслан on 18.11.2024.
//

import Kingfisher
import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    
    @State private var showMore = false
    
    
    init(router: StartRouter) {
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(router: router))
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
            
            VStack(spacing: 50) {
                
                
                VStack {
                    ToolBarView(title: "Profile".localized,
                                foregroundStyle: .titleFont
                    )
                    .padding(.bottom, 16)
                    Image(viewModel.profileImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                    
                    
                    VStack(alignment: .center, spacing: 15) {
                        Text(viewModel.userName)
                            .airbnbCerealFont(.book, size: 24)
                        
                        NavigationLink{
                            ProfileEditeView(
                                userName: $viewModel.userName,
                                userInfo: $viewModel.userInfo,
                                profileImageName: $viewModel.profileImageName
                            )
                        } label: {
                            EditButton()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 30) {
                    Text("About Me")
                        .airbnbCerealFont( AirbnbCerealFont.medium, size: 18)
                    
                    VStack(alignment: .leading) {
                        Text(viewModel.userInfo)
                            .airbnbCerealFont( AirbnbCerealFont.book, size: 16)
                            .lineLimit(4)
                        
                        Button {
                            showMore = true
                        } label: {
                            Text("Read More".localized)
                                .foregroundStyle(.appBlue)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                SignOutButton(action: { viewModel.signOut() } )
                    .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showMore) {
            AboutMeInfo(text: viewModel.userInfo)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ProfileView(router: StartRouter())
}


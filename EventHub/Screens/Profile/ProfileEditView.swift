//
//  ProfileEditView.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 28.11.2024.
//

import Kingfisher
import SwiftUI

struct ProfileEditeView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var userName: String
    @Binding var userInfo: String
    var profileImage: Image
    
    var onAvatarSelected: ((String) -> Void)?
    
    @State private var editName = false
    @State private var editInfo = false
    @State private var showMore = false
    
    @State private var isChangeUserPhoto = false
    
    // MARK: - Constants
    private enum Drawing {
        static let titleTopPadding: CGFloat = 68
        static let horizontalPadding: CGFloat = 20
        static let headerPadding: CGFloat = 20
        static let bottomPadding: CGFloat = 20
        static let blurRadius: CGFloat = 5
        static let changePhotoViewHeight: CGFloat = 300
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
            
            VStack(spacing: 90) {
                VStack {
                    ToolBarView(title: "Profile".localized,
                                foregroundStyle: .titleFont
                    )
                    .padding(.bottom, 16)
                    
                    profileImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                        .onTapGesture {
                            isChangeUserPhoto.toggle()
                        }
                    
                    HStack(spacing: 17) {
                        
                        if editName {
                            HStack {
                                TextField("\(userName)", text: $userName)
                                    .textFieldStyle(.roundedBorder)
                                
                                VStack {
                                    Button {
                                        editName = false
                                    } label: {
                                        Image(systemName: "checkmark")
                                            .resizable()
                                            .foregroundStyle(.appBlue)
                                            .frame(width: 22, height: 22, alignment: .center)
                                    }
                                }
                            }
                        } else {
                            Text(userName)
                                .airbnbCerealFont( AirbnbCerealFont.medium, size: 24)
                            
                            VStack {
                                Button {
                                    editName = true
                                } label: {
                                    Image(.edit)
                                        .resizable()
                                        .foregroundStyle(.appBlue)
                                        .frame(width: 22, height: 22, alignment: .center)
                                }
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 40) {
                    
                    HStack {
                        Text("About Me")
                            .airbnbCerealFont( AirbnbCerealFont.medium, size: 18)
                        
                        VStack(alignment: .leading) {
                            Button {
                                editInfo.toggle()
                            } label: {
                                if editInfo {
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .foregroundStyle(.appBlue)
                                        .frame(width: 22, height: 22, alignment: .center)
                                } else {
                                    Image(.edit)
                                        .resizable()
                                        .foregroundStyle(.appBlue)
                                        .frame(width: 22, height: 22, alignment: .center)
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        if editInfo {
                            TextEditor(text: $userInfo)
                        } else {
                            Text(userInfo)
                                .airbnbCerealFont( AirbnbCerealFont.book, size: 16)
                                .lineLimit(4)
                        }
                        
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
                
                SignOutButton(action: { } )
                    .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
            if isChangeUserPhoto {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isChangeUserPhoto = false
                    }
                
                ChangePhotoView(onAvatarSelected: { avatar in
                    onAvatarSelected?(avatar)
                    isChangeUserPhoto = false
                })
                .frame(height: Drawing.changePhotoViewHeight)
            }
            
        }
        .blur(radius: isChangeUserPhoto ? Drawing.blurRadius : 0)
        .ignoresSafeArea()
        
        
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackBarButtonView(foregroundStyle: .black)
            }
        }
        .sheet(isPresented: $showMore) {
            AboutMeInfo(text: userInfo)
        }
        
    }
}

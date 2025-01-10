//
//  ProfileEditView.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 28.11.2024.
//

import SwiftUI

struct ProfileEditView: View {
    
    // MARK: - Bindings
    @Binding var userName: String
    @Binding var userInfo: String
    @Binding var profileImageName: String
    
    // MARK: - States
    @State private var editName = false
    @State private var editInfo = false
    @State private var showMore = false
    @State private var isChangeUserPhoto = false
    
    // MARK: - Constants
    private enum Drawing {
        // Spacing & Paddings
        static let titleTopPadding: CGFloat = 68
        static let horizontalPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 20
        static let textFieldPadding: CGFloat = 16
        static let bottomPadding: CGFloat = 20
        static let iconPadding: CGFloat = 8
        
        // Sizes
        static let toolBarHeight: CGFloat = 44
        static let profileImageSize: CGFloat = 135
        static let editIconSize: CGFloat = 22
        static let changePhotoViewHeight: CGFloat = 350
        static let textEditorMinHeight: CGFloat = 100
        
        // Other
        static let blurRadius: CGFloat = 5
        static let maxTextLines: Int = 4
        static let largeTextThreshold: Int = 150
        static let cornerRadius: CGFloat = 8
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
                .onTapGesture {
                    isChangeUserPhoto = false
                }
            VStack {
                
                
                // MARK: - Profile Image and Name
                VStack(spacing: Drawing.sectionSpacing) {
                    profileImageView
                        .padding(.bottom, Drawing.bottomPadding)
                    editableNameView
                        .padding(.bottom, Drawing.bottomPadding)
                        .padding(.horizontal, Drawing.horizontalPadding)
                }
                
                // MARK: - About Me Section
                aboutMeSection
                    .padding(.horizontal, Drawing.horizontalPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .blur(radius: isChangeUserPhoto ? Drawing.blurRadius : 0)
            
            // MARK: - Change Photo View
            if isChangeUserPhoto {
                changePhotoOverlay
            }
        }
        // MARK: - ToolBar
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackBarButtonView()
            }
            ToolbarItem(placement: .principal) {
                ToolBarTitleView(
                    title: "Profile".localized
                )
            }
        }
        .navigationBarBackButtonHidden()
    }
}


// MARK: - Subviews
extension ProfileEditView {
    private var profileImageView: some View {
        Image(profileImageName)
            .resizable()
            .scaledToFill()
            .frame(width: Drawing.profileImageSize, height: Drawing.profileImageSize)
            .clipShape(Circle())
            .onTapGesture {
                isChangeUserPhoto.toggle()
            }
    }
    
    private var editableNameView: some View {
        HStack {
            if editName {
                TextField("\(userName)", text: $userName)
                    .airbnbCerealFont(AirbnbCerealFont.medium, size: 24)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.appForegroundStyle)
                    .padding(Drawing.textFieldPadding)
                    .overlay {
                        RoundedRectangle(cornerRadius: Drawing.cornerRadius)
                            .stroke(Color.appLightGray, lineWidth: 0.5)
                    }
                
                Button {
                    withAnimation(.easeInOut) {
                        editName = false
                    }
                } label: {
                    Image(systemName: "checkmark.square")
                        .resizable()
                        .foregroundStyle(.appBlue)
                        .frame(width: Drawing.editIconSize, height: Drawing.editIconSize)
                }
            } else {
                Text(userName)
                    .airbnbCerealFont(AirbnbCerealFont.medium, size: 24)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.appForegroundStyle)
                
                Button {
                    withAnimation(.easeInOut) {
                        editName = true
                    }
                } label: {
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .foregroundStyle(.appBlue)
                        .frame(width: Drawing.editIconSize, height: Drawing.editIconSize)
                }
            }
        }
    }
    
    private var aboutMeSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Drawing.textFieldPadding) {
                HStack {
                    Text("About Me")
                        .airbnbCerealFont(AirbnbCerealFont.medium, size: 18)
                    
                    Button {
                        withAnimation(.easeInOut) {
                            editInfo.toggle()
                        }
                    } label: {
                        Image(systemName: editInfo ? "checkmark.square" : "square.and.pencil")
                            .resizable()
                            .foregroundStyle(.appBlue)
                            .frame(width: Drawing.editIconSize, height: Drawing.editIconSize)
                    }
                }
                
                if editInfo {
                    TextEditor(text: $userInfo)
                        .frame(minHeight: Drawing.textEditorMinHeight, maxHeight: .infinity)
                        .overlay {
                            RoundedRectangle(cornerRadius: Drawing.cornerRadius)
                                .stroke(Color.appLightGray, lineWidth: 0.5)
                        }
                } else {
                    Text(userInfo)
                        .airbnbCerealFont(AirbnbCerealFont.book, size: 16)
                        .lineLimit(showMore ? nil : Drawing.maxTextLines)
                        .animation(.easeInOut, value: showMore)
                    
                    if userInfo.count > Drawing.largeTextThreshold {
                        Button {
                            withAnimation(.easeInOut) {
                                showMore.toggle()
                            }
                        } label: {
                            Text(showMore ? "Read Less" : "Read More")
                                .foregroundStyle(.appBlue)
                        }
                    }
                }
            }
        }
    }
    
    private var changePhotoOverlay: some View {
        return ChangePhotoView(selectedAvatar: $profileImageName)
            .frame(height: Drawing.changePhotoViewHeight)
    }
}

// MARK: - Preview
#Preview {
    ProfileEditView(
        userName: .constant("Joseph"),
        userInfo: .constant("Dlfdfv dfasfa tatatl ladfa"),
        profileImageName: .constant("avatar2")
    )
}

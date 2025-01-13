//
//  ProfileView.swift
//  EventHub
//
//  Created by Руслан on 18.11.2024.
//

import SwiftUI

struct ProfileScreen: View {
    // MARK: - Properties
    @StateObject var viewModel: ProfileViewModel
    @State private var showMore = false
    @State private var isUpdatingProfile = false
    
    // MARK: - Constants
    private enum Drawing {
        // UI Sizes
        static let profileImageSize: CGFloat = 96
        static let spacingBetweenSections: CGFloat = 50
        static let toolbarBottomPadding: CGFloat = 16
        static let signOutButtonBottomPadding: CGFloat = 40
        static let horizontalPadding: CGFloat = 20
        static let cornerRadius: CGFloat = profileImageSize / 2
        
        // Font Sizes
        static let titleFontSize: CGFloat = 24
        static let aboutMeFontSize: CGFloat = 18
        static let infoFontSize: CGFloat = 16
        
        // Text Handling
        static let largeTextThreshold: Int = 150
        static let maxTextLines: Int = 4
        
        // Strings
        static let profileTitle: String = "Profile"
        static let aboutMeTitle: String = "About Me"
        static let readMore: String = "Read More"
        static let readLess: String = "Read Less"
        static let okButtonTitle: String = "Ok"
        static let cancelButtonTitle: String = "Cancel"
    }
    
    // MARK: - Init
    init(router: StartRouter) {
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(router: router))
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            VStack(spacing: Drawing.spacingBetweenSections) {
                profileHeaderSection
                
                aboutMeSection
                Spacer()
                signOutButtonSection
            }
            .padding(.horizontal, Drawing.horizontalPadding)
        }
        .toolbar {
            ToolbarItem(placement: .principal ) {
                ToolBarTitleView(
                    title: Drawing.profileTitle.localized
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: onViewAppear)
        .alert(isPresented: isPresentedAlert(), error: viewModel.error) {
            Button(Drawing.okButtonTitle, role: .destructive) {
                viewModel.tapErrorOk()
            }
            Button(Drawing.cancelButtonTitle, role: .cancel) {
                viewModel.cancelErrorAlert()
            }
        }
    }
}

// MARK: - Subviews
private extension ProfileScreen {
    // Profile Header Section
    var profileHeaderSection: some View {
        VStack {
            Image(viewModel.profileImageName)
                .resizable()
                .scaledToFill()
                .frame(width: Drawing.profileImageSize, height: Drawing.profileImageSize)
                .clipShape(Circle())
            
            VStack(alignment: .center, spacing: 15) {
                Text(viewModel.userName)
                    .airbnbCerealFont(.book, size: Drawing.titleFontSize)
                
                NavigationLink {
                    ProfileEditView(
                        userName: $viewModel.userName,
                        userInfo: $viewModel.userInfo,
                        profileImageName: $viewModel.profileImageName
                    )
                    .onAppear { isUpdatingProfile = true }
                    .onDisappear {
                        updateProfile()
                        isUpdatingProfile = false
                    }
                } label: {
                    EditButton()
                }
            }
        }
    }
    
    // About Me Section
    var aboutMeSection: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text(Drawing.aboutMeTitle.localized)
                .airbnbCerealFont(AirbnbCerealFont.medium, size: Drawing.aboutMeFontSize)
            ScrollView {
                VStack(alignment: .leading) {
                    Text(viewModel.userInfo)
                        .airbnbCerealFont(AirbnbCerealFont.book, size: Drawing.infoFontSize)
                        .lineLimit(showMore ? nil : Drawing.maxTextLines)
                        .animation(.easeInOut, value: showMore)
                    
                    if viewModel.userInfo.count > Drawing.largeTextThreshold {
                        Button {
                            withAnimation(.easeInOut) { showMore.toggle() }
                        } label: {
                            Text(
                                showMore
                                ? Drawing.readLess.localized
                                : Drawing.readMore.localized
                            )
                            .foregroundStyle(.appBlue)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Sign Out Button Section
    var signOutButtonSection: some View {
        SignOutButton(action: { viewModel.showLogoutAlert() })
            .padding(.bottom, Drawing.signOutButtonBottomPadding)
    }
}

// MARK: - Helpers
private extension ProfileScreen {
    func onViewAppear() {
        if !isUpdatingProfile {
            Task { await viewModel.loadCurrentUser() }
        }
    }
    
    func updateProfile() {
        Task { await viewModel.updateProfileInformation() }
    }
    
    func isPresentedAlert() -> Binding<Bool> {
        Binding(get: { viewModel.error != nil },
                set: { isPresenting in
            if isPresenting { return }
        })
    }
}

// MARK: - Preview
#Preview {
    ProfileScreen(router: StartRouter())
}


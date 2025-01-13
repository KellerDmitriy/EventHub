//
//  ResetPassView.swift
//  EventHub
//
//  Created by Emir Byashimov on 30.11.2024.
//

import SwiftUI

struct ResetPassView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) private var presentationMode 

    let emailReqText = "Please enter your email address to request a password reset".localized
    @State private var showSuccessMessage: Bool = false
    @State private var showErrorMessage: Bool = false

    private enum Drawing {
        static let emailTextFontSize: CGFloat = 15
        static let emailTextHorizontalPadding: CGFloat = 16
        static let emailTextFieldHorizontalPadding: CGFloat = 29
        static let emailTextFieldTopPadding: CGFloat = 36
        static let sendButtonTopPadding: CGFloat = 40
        static let sendButtonHorizontalPadding: CGFloat = 52
        static let titleFontSize: CGFloat = 18
    }
    
    var body: some View {
            ZStack {
                BackgroundWithEllipses()

                VStack(alignment: .center, spacing: 0) {
                    Text(emailReqText)
                        .airbnbCerealFont(.book, size: Drawing.emailTextFontSize)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Drawing.emailTextHorizontalPadding)

                    emailTextField()
                        .padding(.top, Drawing.emailTextFieldTopPadding)

                    BlueButtonWithArrow(text: "Send".localized) {
                        handleResetPassword()
                    }
                    .padding(.top, Drawing.sendButtonTopPadding)
                    .padding(.horizontal, Drawing.sendButtonHorizontalPadding)
                    .disabled(viewModel.isLoading || viewModel.email.isEmpty)

                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        BackBarButtonView()
                    }

                    ToolbarItem(placement: .principal) {
                        Text(Resources.Text.resetPassword.localized)
                            .airbnbCerealFont(AirbnbCerealFont.medium, size: Drawing.titleFontSize)
                            .foregroundStyle(.appForegroundStyle)
                    }
                }
                .navigationBarBackButtonHidden()
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }

        private func emailTextField() -> some View {
            AuthTextField(
                textFieldText: $viewModel.email,
                placeholder: "Your email".localized,
                imageName: "mail",
                isSecure: false
            )
            .padding(.horizontal, Drawing.emailTextFieldHorizontalPadding)
        }

        private func handleResetPassword() {
            Task {
                viewModel.isLoading = true
                let success = await viewModel.resetPassword(email: viewModel.email)
                viewModel.isLoading = false

                if success {
                    withAnimation {
                        showErrorMessage = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    withAnimation {
                        showSuccessMessage = false
                        showErrorMessage = true
                    }
                }
            }
        }
    }

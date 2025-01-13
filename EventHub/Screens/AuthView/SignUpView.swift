//
//  SignUpView.swift
//  EventHub
//
//  Created by Emir Byashimov on 22.11.2024.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    // MARK: - Drawing Constants
    private enum Drawing {
        static let titleFontSize: CGFloat = 18
        static let textFieldFontSize: CGFloat = 15
        static let buttonVerticalPadding: CGFloat = 8
        static let horizontalPaddingRatio: CGFloat = 0.1
        static let smallPaddingRatio: CGFloat = 0.05
        static let textFieldTopPadding: CGFloat = 16
        static let textFieldSpacing: CGFloat = 24
        static let buttonSpacing: CGFloat = 32
        static let bottomPadding: CGFloat = 20
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            BackgroundWithEllipses()
                .background(Color.appBackground)

            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let horizontalPadding = screenWidth * Drawing.horizontalPaddingRatio
                let smallPadding = screenWidth * Drawing.smallPaddingRatio

                ZStack {
                    VStack {
                        // Full Name
                        AuthTextField(
                            textFieldText: $viewModel.name,
                            placeholder: "Full name".localized,
                            imageName: "profile",
                            isSecure: false
                        )
                        .padding(.top, Drawing.textFieldTopPadding)

                        // Email
                        AuthTextField(
                            textFieldText: $viewModel.email,
                            placeholder: "Your email".localized,
                            imageName: "mail",
                            isSecure: false
                        )
                        .padding(.top, Drawing.textFieldSpacing)

                        // Password
                        passwordTextField(
                            placeholder: "Your password".localized,
                            textFieldText: $viewModel.password
                        )
                        .padding(.top, Drawing.textFieldSpacing)

                        // Confirm Password
                        passwordTextField(
                            placeholder: "Confirm password".localized,
                            textFieldText: $viewModel.confirmPassword
                        )
                        .padding(.top, Drawing.textFieldSpacing)

                        // Sign Up Button
                        BlueButtonWithArrow(text: "Sign up".localized) {
                            Task {
                                await viewModel.registerUser()
                            }
                        }
                        .padding(.top, Drawing.buttonSpacing)
                        .disabled(viewModel.isLoading)

                        // OR Divider
                        Text("OR")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, Drawing.buttonVerticalPadding)

                        // Google Sign-In Button
                        GoogleButton {
                            Task {
                                try await viewModel.signInWithGoogle()
                            }
                        }

                        Spacer()

                        // Footer
                        HStack {
                            Text("Already have an account?".localized)
                                .airbnbCerealFont(.book, size: Drawing.textFieldFontSize)
                                .foregroundColor(.titleFont)

                            Text("Sign In".localized)
                                .airbnbCerealFont(.book, size: Drawing.textFieldFontSize)
                                .foregroundColor(.appBlue)
                        }
                        .onTapGesture {
                            dismiss()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, Drawing.bottomPadding)
                    }
                    .padding(.top, Drawing.buttonSpacing)
                    .padding(.horizontal, horizontalPadding)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        BackBarButtonView()
                    }

                    ToolbarItem(placement: .principal) {
                        Text(Resources.Text.signUp.localized)
                            .airbnbCerealFont(AirbnbCerealFont.medium, size: Drawing.titleFontSize)
                            .foregroundStyle(.appForegroundStyle)
                    }
                }
                .navigationBarBackButtonHidden()
                .alert(isPresented: isPresentedAlert()) {
                    Alert(
                        title: Text(viewModel.authError == .signUpSuccess ? "Success" : "Error"),
                        message: Text(viewModel.authError?.localizedDescription ?? ""),
                        dismissButton: .default(Text("OK"), action: {
                            if viewModel.authError == .signUpSuccess {
                                viewModel.cancelErrorAlert()
                                dismiss()
                            } else {
                                viewModel.cancelErrorAlert()
                            }
                        })
                    )
                }
            }
        }
    }

    // MARK: - Private Methods
    private func isPresentedAlert() -> Binding<Bool> {
        Binding(
            get: { viewModel.authError != nil },
            set: { isPresenting in
                if !isPresenting {
                    viewModel.authError = nil
                }
            }
        )
    }

    private func passwordTextField(placeholder: String, textFieldText: Binding<String>) -> some View {
        AuthTextField(
            textFieldText: textFieldText,
            placeholder: placeholder,
            imageName: "Lock",
            isSecure: true
        )
    }
}

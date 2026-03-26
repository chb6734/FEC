//
//  AuthView.swift
//  FEC
//
//  로그인 / 회원가입 화면
//

import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let supabaseService = SupabaseService()
    var onAuthenticated: () -> Void

    var body: some View {
        ZStack {
            AppDesign.beige.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // 브랜드
                VStack(spacing: 8) {
                    Text("eunbin")
                        .font(AppDesign.brandFont)
                        .foregroundStyle(AppDesign.navy)
                    Text("오늘 뭐 먹지?")
                        .font(AppDesign.subtitleFont)
                        .foregroundStyle(AppDesign.subtitleGray)
                }

                // 입력 필드
                VStack(spacing: 16) {
                    TextField("이메일", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(AppDesign.cardWhite)
                        .clipShape(RoundedRectangle(cornerRadius: AppDesign.cornerRadius))

                    SecureField("비밀번호", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password)
                        .padding()
                        .background(AppDesign.cardWhite)
                        .clipShape(RoundedRectangle(cornerRadius: AppDesign.cornerRadius))
                }
                .padding(.horizontal, AppDesign.horizontalPadding)

                // 에러 메시지
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(AppDesign.resetRed)
                        .padding(.horizontal, AppDesign.horizontalPadding)
                }

                // 로그인/회원가입 버튼
                Button {
                    Task { await authenticate() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isSignUp ? "회원가입" : "로그인")
                            .font(AppDesign.ctaFont)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canSubmit ? AppDesign.navy : AppDesign.disabledButton)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: AppDesign.cornerRadius))
                .padding(.horizontal, AppDesign.horizontalPadding)
                .disabled(!canSubmit || isLoading)

                // 전환 버튼
                Button {
                    isSignUp.toggle()
                    errorMessage = nil
                } label: {
                    Text(isSignUp ? "이미 계정이 있으신가요? 로그인" : "계정이 없으신가요? 회원가입")
                        .font(.subheadline)
                        .foregroundStyle(AppDesign.navy)
                }

                Spacer()
            }
        }
    }

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6
    }

    private func authenticate() async {
        isLoading = true
        errorMessage = nil

        do {
            if isSignUp {
                try await supabaseService.signUp(email: email, password: password)
            } else {
                try await supabaseService.signIn(email: email, password: password)
            }
            onAuthenticated()
        } catch {
            errorMessage = isSignUp
                ? "회원가입 실패: \(error.localizedDescription)"
                : "로그인 실패: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

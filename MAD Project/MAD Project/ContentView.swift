//
//  ContentView.swift
//  MAD Project
//
//  Created by Patrick Weiss on 26.09.26.
//

import SwiftUI

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""

    enum Field {
        case email
        case password
    }
    @FocusState private var focusedField: Field?

    @State private var isLoggingIn: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    private let validEmail = "test@example.com"
    private let validPassword = "password123"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Email")
                .font(.headline)

            TextField("yourname@example.com", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .disabled(isLoggingIn)
                .onSubmit {
                    focusedField = .password
                }

            Text("Password")
                .font(.headline)
                .padding(.top, 8)

            SecureField("Your password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.password)
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .disabled(isLoggingIn)
                .onSubmit {
                    login()
                }

            HStack {
                Spacer()

                if isLoggingIn {
                    ProgressView()
                        .padding(.top, 16)
                } else {
                    Button(action: login) {
                        Text("Login")
                            .font(.title2)
                    }
                    .disabled(isLoggingIn)
                    .padding(.top, 16)
                }

                Spacer()
            }

            Spacer()
        }
        .padding()
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func login() {
        focusedField = nil

        guard !email.isEmpty else {
            presentAlert(title: "Missing Email", message: "Please enter your email address.")
            return
        }

        guard !password.isEmpty else {
            presentAlert(title: "Missing Password", message: "Please enter your password.")
            return
        }

        isLoggingIn = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.email == self.validEmail && self.password == self.validPassword {
                self.presentAlert(title: "Success", message: "You are now logged in!")
            } else {
                self.presentAlert(title: "Login Failed", message: "Incorrect email or password.")
            }

            self.isLoggingIn = false
        }
    }

    private func presentAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

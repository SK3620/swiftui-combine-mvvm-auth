//
//  ContentView.swift
//  swiftui-combine-mvvm-auth
//
//  Created by 鈴木 健太 on 2024/08/06.
//

import SwiftUI

struct SignUpView: View {
    
    @State var userName: String = ""
    var usernameError: String = "Required"

    @State var email: String = ""
    var emailError: String = "Required"
    
    @State var password: String = ""
    var passwordError: String = "Required"
    
    @State var confirmPassword: String = ""
    var confirmPasswordError: String = "Required"

    var body: some View {
        
        ZStack {
            ColorCodes.primary.color().edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Green Grocery")
                    .font(Font.custom("Noteworthy-Bold", size: 40.0))
                    .foregroundColor(Color.white)
                    .padding(.bottom, 20.0)
                
                
                // $ → プロパティをバインディングとして渡し、同期させる
                AuthTextField(title: "UserName", textValue: $userName, errorValue: usernameError)
                
                AuthTextField(title: "Email", textValue: $email, errorValue: emailError, keyboardType: .emailAddress)
                
                AuthTextField(title: "Password", textValue: $password, errorValue: passwordError, isSecured: true)
                
                AuthTextField(title: "Confitm Password", textValue: $confirmPassword, errorValue: confirmPasswordError, isSecured: true)
                
                Button {
                    signUp()
                } label: {
                    Text("Sign Up Clicked")
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .foregroundColor(Color.white)
                .padding()
                .background(Color.black)
                .cornerRadius(.infinity)
                .padding(.top, 20.0)

            }
            .padding(60)
        }
    }
    
    private func signUp() -> Void {
        print("clicked")
    }
}

#Preview {
    SignUpView()
}

extension ColorCodes {
    
    func color() -> Color {
        
        switch self {
        case .primary:
            return Color(red: 79/255, green: 139/255, blue: 43/255)
            
        case .success:
            return Color(red: 0, green: 0, blue: 0)
            
        case .failure:
            return Color(red: 219/255, green: 12/255, blue: 12/255)
            
        case .background:
            return Color(red: 239/255, green: 243/255, blue: 244/255, opacity: 1.0)

        }
    }
}

struct AuthTextField: View {
    
    var title: String
    @Binding var textValue: String
    var errorValue: String
    var isSecured: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack {
            if isSecured {
                SecureField(title, text: $textValue)
                    .padding()
                    .background(Color(ColorCodes.background.color()))
                    .cornerRadius(5.0)
                    .keyboardType(keyboardType)
            } else {
                TextField(title, text: $textValue)
                    .padding()
                    .background(Color(ColorCodes.background.color()))
                    .cornerRadius(5.0)
                    .keyboardType(keyboardType)
            }
            
            Text(errorValue)
                .fontWeight(.light)
                .foregroundStyle(ColorCodes.failure.color())
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
        }
    }
}

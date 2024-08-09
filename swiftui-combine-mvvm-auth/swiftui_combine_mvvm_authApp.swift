//
//  swiftui_combine_mvvm_authApp.swift
//  swiftui-combine-mvvm-auth
//
//  Created by 鈴木 健太 on 2024/08/06.
//

import SwiftUI

@main
struct swiftui_combine_mvvm_authApp: App {
    
    let viewModel = SignUpViewModel(authApi: AuthService.shared, authServiceParser: AuthServiceParser.shared)
    
    var body: some Scene {
        WindowGroup {
            SignUpView(viewModel: viewModel)
        }
    }
}

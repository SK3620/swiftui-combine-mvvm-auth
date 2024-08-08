//
//  AuthModel.swift
//  swiftui-combine-mvvm-auth
//
//  Created by 鈴木 健太 on 2024/08/08.
//

import Foundation

struct AuthModel: Codable {
    let name: String
    let email: String
    let password: String
    
    init(name: String = "", email: String, password: String) {
        self.name = name
        self.email = email
        self.password = password
    }
}

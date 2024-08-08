//
//  SignUpErrorModel.swift
//  swiftui-combine-mvvm-auth
//
//  Created by 鈴木 健太 on 2024/08/08.
//

import Foundation

struct SignUpErrorModel: Codable {
    let validationErrors: ValidationErrors
    
    enum CodingKeys: String, CodingKey {
        case validationErrors = "validation_erros"
    }
}

struct ValidationErrors: Codable {
    let name, email, password: [String]?
}

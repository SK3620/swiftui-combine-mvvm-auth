//
//  AuthAPI.swift
//  swiftui-combine-mvvm-auth
//
//  Created by 鈴木 健太 on 2024/08/08.
//

import Foundation
import Combine

protocol AuthAPI {
    //    func checkEmail(email: String) -> Future<Bool, Never>
    //    func signUp(userName: String, email: String, password: String) -> Future<(statusCode: Int, data: Data), Error>
    
//    func signUp(userName: String, email: String, password: String, success: @escaping (_ token: String, _ tokenType: String, _ expiresIn: Int) -> Void, failure: @escaping (_ error: String) -> Void)
    
    func signUp(userName: String, email: String, password: String) -> Future<(statusCode: Int, data: Data), Error>
    
    func checkEmail(email: String) -> Future<Bool, Never>

    //    func login(email: String, password: String, success: @escaping (_ token: String) -> Void, failure: @escaping (_ error: String) -> Void)
    //
    //    func validate(token: String, success: @escaping (_ user: User) -> Void, failuer: @escaping (_ error: String) -> Void)
    //
    //    func refreshToken(token: String, success: @escaping (_ token: String) -> Void, failure: @escaping (_ error: String) -> Void)
    //
    //    func logout(token: String, success: @escaping (_ token: String) -> Void, failure: @escaping (_ error: String) -> Void)
}

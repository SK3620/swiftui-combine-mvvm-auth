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
    
    // Future → SwiftのCombineフレームワークで使われる型の一つで、非同期操作の結果を返す。この型は、まだ値が決定していないが、将来的に決定することが期待される値を扱う。
    
    // Futureの使い所
    // Futureの使い所としては、「Aの処理が完了したらBの処理を実行する」という、これまで通信処理などで利用していたコールバック処理をCombineで実装する（Combineに置き換える）場合に使います。
    
    // (statusCode: Int, data: Data)タプル型オブジェクトをOutputとして流す
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

//
//  SignUpViewModel.swift
//  swiftui-combine-mvvm-auth
//
//  Created by 鈴木 健太 on 2024/08/06.
//

import Foundation
import Combine

final class AAA {
    var a: String = ""
}

class SignUpViewModel: ObservableObject {
    
    private var cancellableBag = Set<AnyCancellable>()
    
    @Published var userName: String = ""
    var usernameError: String = ""
    
    @Published var email: String = ""
    var emailError: String = ""
    
    @Published var password: String = ""
    var passwordError: String = ""
    
    @Published var confirmPassword: String = ""
    var confirmPasswordError: String = ""
    
    // <Bool, Never> → publishする値の型はBoolとNever
    // Never → エラーをpublishしない
    private var usernameValidPublisher: AnyPublisher<Bool, Never> {
        return $userName
        // 受け取った値をmapで変換
            .map { !$0.isEmpty }
            .eraseToAnyPublisher()
    }
    
    // struct AnyPublisher<Output, Failure> where Failure : Error
    private var emailRequiredPublisher: AnyPublisher<(email: String, isValid: Bool), Never> {
        // $email → 値が変更されるたびにその変更値を発行するパブリッシャー
        return $email
            .map({ str in 
                /*
                 str: Published<String>.Publisher.Output
                 Published<String> : @Published 属性を持つプロパティの型が String
                 Published<String>.Publisher: @Published 属性が生成するパブリッシャーの型
                 Published<String>.Publisher.Output: Published<String>.Publisher が発行する値の型、つまり Output型（エイリアス） == String型
                 → 要するに、stgは、結局は、単なるString型を指している
                
                 タプルを生成
                 このプロパティ emailRequiredPublisher は、(email: String, isValid: Bool) のタプルを発行する AnyPublisher を返す
                 */
                return (email: str, isValid: !str.isEmpty)
            })
            .eraseToAnyPublisher()
        /*
        // func eraseToAnyPublisher() -> AnyPublisher<Self.Output, Self.Failure>
        // Self は、特定のプロトコルに準拠しているクラス、構造体、または列挙型内で使われる
        // このメソッドは、extension Publisher{}内で定義されている
         // すなわち、下のself.Output, self.Failuerのこと
         protocol Publisher {
        associatedtype Output
        associatedtype Failure: Error
        
        func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input
         .....
         }
         */
    }
    
    private var emailValidPublisher: AnyPublisher<(email: String, isValid: Bool), Never> {
        // emailRequiredPublisherから発行されるタプルを受け取り、それをさらに加工
        return emailRequiredPublisher
            .filter { $0.isValid }
            .map { (email: $0.email, isValid: $0.email.isValidEmail())}
            .eraseToAnyPublisher()
    }
    
    private var passwordRequiredPublisher: AnyPublisher<(password: String, isValid: Bool), Never> {
        return $password
            .map { (password: $0, isValid: !$0.isEmpty) }
            .eraseToAnyPublisher()
    }
    
    private var passwordValidPublisher: AnyPublisher<Bool, Never> {
        return passwordRequiredPublisher
            .filter { $0.isValid }
            .map { $0.password.isValidPassword() }
            .eraseToAnyPublisher()
    }
    
    private var confirmPasswordRequiredPublisher: AnyPublisher<(password: String, isValid: Bool), Never> {
        return $confirmPassword
            .map { (password: $0, isValid: !$0.isEmpty) }
            .eraseToAnyPublisher()
    }
    
    private var passwordEqualPublisher: AnyPublisher<Bool, Never> {
        // 2つのパブリッシャーの最新の値を組み合わせ、それぞれの値が更新されるたびに新しい値を発行するコンバイナーオペレーター
        return Publishers.CombineLatest($password, $confirmPassword)
            .filter { !$0.0.isEmpty && !$0.1.isEmpty}
            .map { password, confirm in
                return password == confirm
            }
            .eraseToAnyPublisher()
    }
    
    init() {
        
        usernameValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0 ? "" : "Username is missing" }
        // on → to:で指定したプロパティを含んでいるobjectのインスタンス
        // to → on:で指定したobjectが持つプロパティ（keyPath）
            .assign(to: \.usernameError, on: self)
            .store(in: &cancellableBag)
        
        // 要するに、上記は↓と同じ。
        /*
        $userName.map { !$0.isEmpty ? "" : "Username is missing"  }
            .assign(to: \.usernameError, on: self)
            .store(in: &cancellableBag)
         */
        
        emailRequiredPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.isValid ? "" : "Email is Missing"}
            .assign(to: \.emailError, on: self)
            .store(in: &cancellableBag)
        
        emailValidPublisher
            .receive(on: RunLoop.main)
            .map { $0.isValid ? "" : "Email is not valid"}
            .assign(to: \.emailError, on: self)
            .store(in: &cancellableBag)
        
        passwordRequiredPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.isValid ? "" : "Password is missing" }
            .assign(to: \.passwordError, on: self)
            .store(in: &cancellableBag)
        
        passwordValidPublisher
            .receive(on: RunLoop.main)
            .map { $0 ? "" : "Password must be 8 characters"}
            .assign(to: \.passwordError, on: self)
            .store(in: &cancellableBag)
        
        confirmPasswordRequiredPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.isValid ? "" : "Confirm Password is missing" }
            .assign(to: \.passwordError, on: self)
            .store(in: &cancellableBag)
        
        passwordEqualPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0 ? "" : "Passwords dose not match" }
            .assign(to: \.confirmPasswordError, on: self)
            .store(in: &cancellableBag)
    }
    
    deinit {
        cancellableBag.removeAll()
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        return true // とりあえず、trueで返しておく
    }
}


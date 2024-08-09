//
//  SignUpViewModel.swift
//  swiftui-combine-mvvm-auth
//
//  Created by 鈴木 健太 on 2024/08/06.
//

import Foundation
import Combine

class StatusViewModel: ObservableObject {
    
    var title: String
    var color: ColorCodes
    
    init(title: String, color: ColorCodes) {
        self.title = title
        self.color = color
    }
}

class SignUpViewModel: ObservableObject {
    
    private let authApi: AuthAPI
    private let authServiceParser: AuthServiceParseable
    private var cancellableBag = Set<AnyCancellable>()
    
    @Published var userName: String = ""
    @Published var usernameError: String = ""
    
    @Published var email: String = ""
    @Published var emailError: String = ""
    
    @Published var password: String = ""
    @Published var passwordError: String = ""
    
    @Published var confirmPassword: String = ""
    @Published var confirmPasswordError: String = ""
    
    @Published var enableSignUp: Bool = false
    @Published var statusViewModel: StatusViewModel = StatusViewModel(title: "", color: .success)
    
    // <Bool, Never> → publishする値の型はBoolとNever
    // Never → エラーをpublishしない
    private var usernameValidPublisher: AnyPublisher<Bool, Never> {
        return $userName
        // 受け取った値をmapで変換
        // Bool型を発行するPublisherに変換する
            .map { !$0.isEmpty }
            .eraseToAnyPublisher()
    }
    
    // struct AnyPublisher<Output, Failure> where Failure : Error
    private var emailRequiredPublisher: AnyPublisher<(email: String, isValid: Bool), Never> {
        // $email → 値が変更されるたびにその変更値を発行するパブリッシャー
        return $email
            .map({ str in 
                /*
                 このmapメソッドの目的は、元のpublisher（self）→（$emailすなわちPublished<String>.Publisherのこと）にmap変換を適用させて、パブリッシャーが発行する値 (Output) を別の型 (T) に変換
                 str: Published<String>.Publisher.Output
                 Published<String> : @Published 属性を持つプロパティの型が String
                 Published<String>.Publisher: @Published 属性が生成するパブリッシャーの型
                 Published<String>.Publisher.Output: Published<String>.Publisher が発行する値の型、つまり Output型（エイリアス） == String型
                 → 要するに、stgは、結局は、単なるString型を指している
                
                 タプルを生成
                 このプロパティ emailRequiredPublisher は、(email: String, isValid: Bool) のタプルを発行する AnyPublisher を返す
                 原理は不明だが、このOutputの型が、(email: String, isValid: Bool)となる
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
         そして、今回のSelfとは、このメソッドを呼び出している特定のパブリッシャー型となる（mapの戻り値であるPublishers.Map<Published<String>.Publisher, (email: str, isValid: !str.isEmpty)>が該当）
         */
    }
    
    private var emailValidPublisher: AnyPublisher<(email: String, isValid: Bool), Never> {
        // emailRequiredPublisherから発行されるタプルを受け取り、それをさらに加工
        return emailRequiredPublisher
            .filter { $0.isValid }
            .map { (email: $0.email, isValid: $0.email.isValidEmail())}
            .eraseToAnyPublisher()
    }
    
    private var emailServerValidPublisher: AnyPublisher<Bool, Never> {
        return emailValidPublisher
            .filter { $0.isValid }
            .map { $0.email }
        // debounce: 使用例: ユーザーがテキストフィールドに入力している場合など、入力途中の一時的な値を無視して、ある程度まとまった後の最後の入力値を処理したいときに使われます。この例では、メールアドレスのバリデーション後の値を処理する前に、ユーザーが入力を止めてから0.5秒間待って、入力が確定したとみなすことで、不要なAPIリクエストなどを避けることができます。
            .debounce(for: 0.5, scheduler: RunLoop.main)
        // removeDuplicates: 連続して同じ値が流れてきた場合、その重複を取り除き、初回の値だけを流すオペレーターです。もし前回と同じ値が連続してストリームに現れた場合、その重複した値をストリームから取り除きます。同じ値が続かない場合には、その値は通常どおり流れます。
            .removeDuplicates()
        /*
         func flatMap<P>(
             maxPublishers: Subscribers.Demand = .unlimited, ← ここはどうでもいい
             _ transform: @escaping (Self.Output) -> P
         ) -> Publishers.FlatMap<P, Self> where P : Publisher, P.Failure == Never
         
         P = Future<Bool, Never> ということになる？
         よって、下のflatMapの戻り値は、
         Publishers.FlatMap<Future<Bool, Never>, Self> where Future<Bool, Never> : Publisher, Future<Bool, Never>.Failure == Never
         */
            .flatMap { [authApi] in authApi.checkEmail(email: $0) }
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
    
    init(authApi: AuthAPI, authServiceParser: AuthServiceParseable) {
        
        self.authApi = authApi
        self.authServiceParser = authServiceParser
        
        usernameValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0 ? "" : "Username is missing" }
        // on → to:で指定したプロパティを含んでいるobjectのインスタンス
        // to → on:で指定したobjectが持つプロパティ（keyPath）
            .assign(to: \.usernameError, on: self)
            // An AnyCancellable instance automatically calls cancel() when deinitialized.
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
        
        emailServerValidPublisher
            .receive(on: RunLoop.main)
            .map { $0 ? "" : "Email is already used"}
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
        
        Publishers.CombineLatest4(usernameValidPublisher, emailServerValidPublisher, passwordValidPublisher, passwordEqualPublisher)
            .map{ userName, email, password, confirm in
                return userName && email && password && confirm
            }
            .receive(on: RunLoop.main)
            .assign(to: \.enableSignUp, on: self)
            .store(in: &cancellableBag)
    }
    
    deinit {
        cancellableBag.removeAll()
    }
}

extension SignUpViewModel {
    
    func signUp() -> Void {
        // signUpで実際のHTTP通信を行い、そのレスポンスデータとして $0: (statusCode: Int, data: Data)がある
        authApi.signUp(userName: userName, email: email, password: password)
            .flatMap { [authServiceParser] in
                // 受け取ったjsonデータのパース作業（バリデーションのパースも含む）
                authServiceParser.parseSignUpResponse(statuCode: $0.statusCode, data: $0.data)
            }
            .map { result in
                // result: AuthResult<TokenResponseModel>または<Error>をpublishしてくる
                // おそらくだけど、.success(〜)で値渡している意味ってある？
                switch(result) {
                case .success:
                    return StatusViewModel(title: "Sign Up is scuccessfully", color: ColorCodes.success)
                case .failure:
                    return StatusViewModel(title: "Sign Up failed", color: ColorCodes.failure)
                }
            }
            .receive(on: RunLoop.main)
        // replaceError: エラーが発生した場合、そのエラーはなかったこととし正常な値（Publisher.Output）に置き換えます。似たような機能に、nilを置き換えるreplaceNilや、空を置き換えるreplaceEmptyがあります。
            .replaceError(with: StatusViewModel(title: "Sign Up failed", color: ColorCodes.failure))
        // handleEvents: 流れてくるいろんなイベントに対して、自由に特定の処理をさせる
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.userName = ""
                self?.email = ""
                self?.passwordError = ""
                self?.confirmPassword = ""
            })
            .assign(to: \.statusViewModel, on: self)
            .store(in: &cancellableBag)
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


//
//  AuthService.swift
//  swiftui-combine-mvvm-auth
//
//  Created by 鈴木 健太 on 2024/08/08.
//

import Foundation
import Combine

enum SignUpError: Error {
    case emailExists
    case invalidData
    case invalidJSON
    case error(error: String)
}

enum AuthResult<T> {
    case success(value: T)
    case failure(message: String)
}

class AuthService {
    lazy var httpService = AuthHttpService()
    static let shared: AuthService = AuthService()
    private init(){}
}

extension AuthService: AuthAPI {
    
    func signUp(userName: String, email: String, password: String) -> Future<(statusCode: Int, data: Data), Error> {
        
        // Futureはインスタンスが生成された時点で実行されてしまう。なので、以下も実行されてしまうので、Deffered？をつけるべき？
        return Future<(statusCode: Int, data: Data), Error> { [httpService] promise in
            // promise: (Result<(statusCode: Int, data: Data), any Error>) -> Void
            // promiseは引数に (Result<(statusCode: Int, data: Data), any Error>)を受け取り、void型を返す関数である
            // なので、promise(.success(値))みたいな書き方可能
            do {
                try AuthHttpRouter.signUp(AuthModel(name: userName, email: email, password: password))
                    .request(usingHttpService: httpService)
                    .responseJSON { (response) in
                        print("SignUp status code: \(String(describing: response.response?.statusCode))")
                        print("Respnse Body: \(String(data: (response.request?.httpBody)!, encoding: .utf8) as String?)")
                        
                        guard let statusCode = response.response?.statusCode, let data  = response.data, statusCode == 200 else {
                            promise(.failure(SignUpError.invalidData))
                            return
                        }
                        
                        promise(.success((statusCode: statusCode, data: data)))
                        
                        /*
                        if response.response?.statusCode  == 200 {
                            let dict = response.result.value as? [String: Any]
                            
                            guard let accessToken = dict?["access_token"] as? String, let tokenType = dict?["token_type"] as? String,
                                  let expiresIn = dict?["expires_in"] as? Int
                            else { return }
                            success(accessToken, tokenType, expiresIn)
                            return
                        }
                        
                        if response.response?.statusCode == 401 {
                            do {
                                if let data = response.data {
                                    let authError = try JSONEncoder().decode(SingUpError.self, from: data)
                                    if let nameError = authError.validationErros.name?.first {
                                        failure(nameError)
                                        return
                                    }
                                    if let emailError = authError.validationErrors.email?.first {
                                        failure(emailError)
                                        return
                                    }
                                    if let passwordError = authError.validationErrors.password?.first {
                                        failure(passwordError)
                                        return
                                    }
                                }
                            } catch {
                                print("Signing in failed = \(error)")
                                failure("Signing in failed")
                            }
                        }
                         */
                    }
            } catch {
                print("Signing in failed = \(error)")
                promise(.failure(SignUpError.invalidData))
            }
        }
    }
    
    /*
    func signUp(userName: String, email: String, password: String, success: @escaping (String, String, Int) -> Void, failure: @escaping (String) -> Void) {
        
        do {
            try AuthHttpRouter.signUp(AuthModel(name: userName, email: email, password: password))
                .request(usingHttpService: httpService)
                .responseJSON { (response) in
                    print("SignUp status code: \(String(describing: response.response?.statusCode))")
                    print("Respnse Body: \(String(data: (response.request?.httpBody)!, encoding: .utf8) as String?)")
                    
                    if response.response?.statusCode  == 200 {
                        let dict = response.result.value as? [String: Any]
                        
                        guard let accessToken = dict?["access_token"] as? String, let tokenType = dict?["token_type"] as? String,
                              let expiresIn = dict?["expires_in"] as? Int
                        else { return }
                        success(accessToken, tokenType, expiresIn)
                        return
                    }
                    
                    if response.response?.statusCode == 400 {
                        do {
                            if let data = response.data {
                                let authError = try JSONEncoder().decode(SingUpError.self, from: data)
                                if let nameError = authError.validationErros.name?.first {
                                    failure(nameError)
                                    return
                                }
                                if let emailError = authError.validationErrors.email?.first {
                                    failure(emailError)
                                    return
                                }
                                if let passwordError = authError.validationErrors.password?.first {
                                    failure(passwordError)
                                    return
                                }
                            }
                        } catch {
                            print("Signing in failed = \(error)")
                            failure("Signing in failed")
                        }
                    }
                }
        } catch {
            print("Signing in failed = \(error)")
            failure("Signing in failed")
        }
    }
     */
    
    /*
    func login(email: String, password: String, success: @escaping (_ token: String) -> Void, failure: @escaping (_ error: String) -> Void) {
        do {
            AuthHttpRouter.login(AuthModel(email: email, password: password)).request(usingHttpservice: httpService).responseJson {
                response in
                
                if response.response?.statusCode  == 200 {
                    let dict = response.result.value as? [String: Any]
                    
                    guard let token = dict?["token"] as? String else { return }
                    success(token)
                }
                
                if response.response?.statusCode == 401 {
                    do {
                        if let data = response.data {
                            let loginError = try JSONDecoder().decode(LoginError.self, from: data)
                            failure(loginError)
                        }
                    } catch {
                        failure("Login Failed = \(error)")
                    }
                }
            }
        } catch {
            print("login failed = \(error)")
            failure("Login failed = \(error)")
        }
    }
     */
    
    
    func checkEmail(email: String) -> Future<Bool, Never> {
        
        return Future<Bool, Never> { [httpService] promise in
            do {
                try AuthHttpRouter.valudateEmail(email: email).request(usingHttpService: httpService).responseJSON {
                    (response) in
                    
                    guard response.response?.statusCode == 200 else {
                        promise(.success(false))
                        return
                    }
                    promise(.success(true))
                    
                    /*
                    guard response.response?.statusCode  == 200 else {
                        if let data = response.data {
                            do {
                                let logoutError = try JSONDecoder().decode(ValidationErrors.self, from: data)
                                failure(logoutError.message)
                            } catch {
                                failure("Token validation failed = \(error)")
                            }
                        }
                        return
                    }
                    
                    if let responseData = response.data {
                        do {
                            let validatioinResponse = try JSONDecoder().decode(ValidationResponse, from: responseData)
                            success(validatioinResponse.user)
                        } catch {
                            failure("Token validation failed = \(error)")
                        }
                    }
                     */
                }
            } catch {
                promise(.success(true))
            }
        }
    }
    
    /*
    func validate(token: String, success: @escaping (User) -> Void, failure: @escaping (String) -> Void){
        do {
            
            AuthHttpRouter.validate(token: token).request(usingHttpservice: httpService).responseJson {
                response in
                
                guard response.response?.statusCode  == 200 else {
                    if let data = response.data {
                        do {
                            let logoutError = try JSONDecoder().decode(ValidationError.self, from: data)
                            failure(logoutError.message)
                        } catch {
                            failure("Token validation failed = \(error)")
                        }
                    }
                    return
                }
                
                if let responseData = response.data {
                    do {
                        let validatioinResponse = try JSONDecoder().decode(ValidationResponse, from: responseData)
                        success(validatioinResponse.user)
                    } catch {
                        failure("Token validation failed = \(error)")
                    }
                }
            }
        } catch {
            failure("Token validation failed")
        }
    }
     */
    
    /*
    func refreshToken(token: String, success: @escaping (String) -> Void, failure: @escaping (String) -> Void) {
        do {
            
            AuthHttpRouter.refreshToken(token: token).request(usingHttpservice: httpService).responseJson {
                response in
                
                guard response.response?.statusCode  == 200 else {
                    if let data = response.data {
                        do {
                            let validationError = try JSONDecoder().decode(ValidationError.self, from: data)
                            failure(validationError.message)
                        } catch {
                            failure("Token refresh failed = \(error)")
                        }
                    }
                    return
                }
                let dict = response.result.value as? [String: Any]
                guard let token = dict?["token"] as? String else {
                    return
                }
                success(token)
            }
        } catch {
            failure("Token refresh failed = \(error)")
        }
    }
     */
    
    
    /*
    func logout(token: String, success: @escaping (String) -> Void, failure: @escaping (String) -> Void) {
        do {
            
            try AuthHttpRouter.logout(token: token).request(usingHttpservice: httpService).responseJson {
                response in
                
                guard response.response?.statusCode  == 200 else {
                    
                    let dict = response.result.value as? [String: Any]
                    guard let message = dict?["message"] as? String else {
                        return
                    }
                    success(message)
                    
                    if respose.response?.statusCode == 401 {
                        if let data = respose.data {
                            do {
                                let logoutError = try JSONDecoder().decode(LogoutError.self, from: data)
                            } catch {
                                failure("log out failed = \(error)")
                            }
                        }
                    }
                }
            }
        } catch {
            failure("Token refresh failed = \(error)")
        }
    }
     */
}

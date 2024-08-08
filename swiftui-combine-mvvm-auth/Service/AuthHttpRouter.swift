//
//  AuthHttpRouter.swift
//  swiftui-combine-mvvm-auth
//
//  Created by 鈴木 健太 on 2024/08/08.
//

import Alamofire

enum AuthHttpRouter {
    case signUp(AuthModel)
    case valudateEmail(email: String)
//    case validate(token: String)
//    case refreshToken(token: String)
//    case logout(token: String)
}

extension AuthHttpRouter: HttpRouter {
    
    var baseUrlString: String {
        return "http://〜〜〜"
    }
    
    var path: String {
        switch (self) {
            //        case .login:
            //            return "login"
        case .signUp:
            return "register"
        case .valudateEmail:
            return "validate/email"
            //        case .refreshToken:
            //            return "token/refresh"
            //        case .logout:
            //            return "logout"
        }
    }
    
    var method: HTTPMethod {
        switch (self) {
        case .signUp, .valudateEmail:
            return .post
            //        case .valudateEmail:
            //            return .get
        }
    }
    
    var headers: HTTPHeaders? {
        switch (self) {
        case .signUp, .valudateEmail:
            return ["Content-Type": "application/json; charset=UTF-8"]
            //        case .valudateEmail, .refreshToken(let token), .logout(let token):
            //            return [
            //                "Authorization": "Bearer \(token)",
            //                "Content-Type": "application/json; charset=UTF-8"
            //            ]
        }
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    func body() throws -> Data? {
        switch self {
            //        case .login(let user):
            //            return try JSONDecoder().encode(user)
            //        case .logout:
            //            return nil
            //        case .validate:
            //            return nil
            //        case .refreshToken:
            //            return nil
            //        case .signUp(let user):
            //            return try JSONEncoder().encode(user)
            
        case .signUp(let user):
            return try JSONEncoder().encode(user)
        case .valudateEmail(let email):
            return try JSONEncoder().encode(["email": email])
            
        }
    }
}

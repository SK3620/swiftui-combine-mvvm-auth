//
//  AuthHttpService.swift
//  swiftui-combine-mvvm-auth
//
//  Created by 鈴木 健太 on 2024/08/08.
//
import Alamofire

final class AuthHttpService: HttpService {
    var sessionManager: Session = Session.default
    
    func request(_ urlRequest: URLRequestConvertible) -> DataRequest {
        return sessionManager.request(urlRequest).validate(statusCode: 200..<400)
    }
}

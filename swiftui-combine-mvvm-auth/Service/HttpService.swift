//
//  HttpService.swift
//  swiftui-combine-mvvm-auth
//
//  Created by 鈴木 健太 on 2024/08/08.
//

import Alamofire

protocol HttpService {
    var sessionManager: Session { get set }
    func request(_ urlRequest: URLRequestConvertible) -> DataRequest
}

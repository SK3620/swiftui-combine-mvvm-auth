//
//  AuthHttpService.swift
//  swiftui-combine-mvvm-auth
//
//  Created by 鈴木 健太 on 2024/08/08.
//
import Alamofire

// final: このクラスが継承できないことを示します。finalを使うと、他のクラスがAuthHttpServiceをサブクラスとして継承することが禁止
final class AuthHttpService: HttpService {
    // Session: HTTPリクエストを送信するための設定やカスタマイズを管理
    // .default: 標準的なセッション管理
    var sessionManager: Session = Session.default
    
    func request(_ urlRequest: URLRequestConvertible) -> DataRequest {
        return sessionManager.request(urlRequest).validate(statusCode: 200..<400)
            // .validate(statusCode: 200..<400): 返されたレスポンスのステータスコードが200から399の範囲内であることを検証します。この範囲外のステータスコード（例えば404や500など）に対してはエラーを発生させます。
            // DataRequest: このメソッドはDataRequestを返します。DataRequestは、Alamofireにおけるデータリクエストのオブジェクトで、リクエストのレスポンスを処理するために使用します。
    }
}

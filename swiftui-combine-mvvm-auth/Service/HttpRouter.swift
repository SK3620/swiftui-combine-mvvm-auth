//
//  HttpRouter.swift
//  swiftui-combine-mvvm-auth
//
//  Created by 鈴木 健太 on 2024/08/08.
//

import Alamofire

protocol HttpRouter: URLRequestConvertible {
    
    var baseUrlString: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get }
    func body() throws -> Data?
    
    func request(usingHttpService service: HttpService) throws -> DataRequest
}

extension HttpRouter {
    
    var paratmeter: Parameters? { return nil }
    func body() throws -> Data? { return nil}
    
    func asURLRequest() throws -> URLRequest {
        var url = try baseUrlString.asURL()
        url.appendingPathComponent(path)
        
        var request = try URLRequest(url: url, method: method, headers: headers)
        request.httpBody = try body()
        return request
    }
    
    func request(usingHttpService service: HttpService) throws -> DataRequest {
        return try service.request(asURLRequest())
    }

}


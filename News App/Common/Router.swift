//
//  Router.swift
//  News App
//
//  Created by Mohan AC on 13/02/22.
//

import Foundation

struct Router {
    
    func buildRequest(with endPoint:EndPointType, bodyParam:Data?) -> URLRequest? {
        
        var urlRequest:URLRequest?
        urlRequest = createRequest(with: endPoint, appending: bodyParam)
        urlRequest?.httpMethod = "GET"
        
        return urlRequest
    }
    
    private func createRequest(with endPoint:EndPointType,appending bodyParam:Data? = nil) -> URLRequest? {
        
        if let url = URL(string: endPoint.urlPath) {
            var urlRequest =  URLRequest.init(url: url)
            urlRequest.httpBody = bodyParam
            
            return urlRequest
        }
        return nil
    }
    
}

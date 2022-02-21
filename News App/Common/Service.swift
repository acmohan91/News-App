//
//  Service.swift
//  News App
//
//  Created by Mohan AC on 13/02/22.
//

import Foundation

typealias anyDictionary = [String : Any]
typealias StringDictionary = [String : String]

enum Result<T:Decodable> {
    case success(data:T)
    case failure(message:String)
    case error(err:NetworkError)
}

struct WebService<E:EndPointType> {
    
    let requestInfo:E
    var bodyParam:Data?
    
    let router = Router()
    let parser = Parser()
    
    
    
    init(endpoint:E, urlParam:anyDictionary? = nil,httpBody:Data? = nil) {
        requestInfo = endpoint
        bodyParam = httpBody
    }
    
    var networkSession:URLSession {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }
    
    func connect<T:Decodable>(callback:@escaping (Result<T>)->()) {
        
        //        guard Internet.shared.isAvailable else {
        //            callback(Result<T>.error(err: NetworkError.noInternet))
        //            return
        //        }
        
        if let request = router.buildRequest(with: requestInfo, bodyParam: bodyParam) {
            self.networkSession.dataTask(with: request) { (responseData, response, error) in
                
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        callback(Result<T>.error(err: NetworkError.serverError))
                    }
                    return
                }
                
                guard error == nil else {
                    DispatchQueue.main.async {
                        callback(Result<T>.error(err: NetworkError.serverError))
                    }
                    return
                }
                
                if let data = responseData {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? anyDictionary {
#if DEBUG
                            print("EndPoint: ",request.url?.absoluteString ?? "")
                            //print(data.prettyPrintedJSONString!)
#endif
                            
                            switch httpResponse.statusCode {
                                
                            case 200:
                                let result = self.parser.decodeResponse(type: T.self, with: json)
                                DispatchQueue.main.async {
                                    callback(result)
                                }
                                
                            default:
                                let result = self.parser.decodeResponse(type: T.self, with: json)
                                DispatchQueue.main.async {
                                    callback(result)
                                }
                            }
                        } else {
                            print("JOSN SERIALISATION ERROR")
                        }
                    } catch  {
                        print(error)
                        DispatchQueue.main.async {
                            callback(Result<T>.error(err: NetworkError.inValidData))
                        }
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        callback(Result<T>.error(err: NetworkError.inValidData))
                    }
                }
            }.resume()
        } else {
            print("block error")
        }
        
        
    }
}

enum NetworkError: LocalizedError {
    
    case serverError
    case unauthorised
    case noInternet
    case jsonDecodeError
    case inValidData
    
    var sayWhy: String {
        switch self {
        case .serverError:
            return "Connection timed out. Please try again when you have established a stable connection."
        case .noInternet:
            return "It seems like you are not connected to the Internet. Please try again when you have established a connection."
        case .unauthorised:
            return "Unauthorised or Token Expired"
        case .jsonDecodeError:
            return "Parsing Error"
        case .inValidData:
            return "Internal server error"
        }
    }
}

extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
}

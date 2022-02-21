//
//  Parser.swift
//  News App
//
//  Created by Mohan AC on 13/02/22.
//

import Foundation

struct Parser {
    
    private func convertObject<T>(value:T) -> Data {
        let responseData = value as! anyDictionary
        var data = Data()
        if let newsObj = responseData["articles"] {
            do {
                data =  try JSONSerialization.data(withJSONObject: newsObj, options:.prettyPrinted)
            }
            catch (let error) {
                print(error)
            }
        }
        else {
            do {
                data =  try JSONSerialization.data(withJSONObject: responseData, options:.prettyPrinted)
            }
            catch (let error) {
                print(error)
            }
        }
        return data
    }
    
    func decodeResponse<T:Decodable>(type:T.Type,with json:anyDictionary)-> Result<T> {
        
        do {
            let decoder = JSONDecoder()
            let data = convertObject(value: json)
            
            if let status = json["status"] as? String {
                if status == "ok" {
                    let model = try decoder.decode(type.self, from: data)
                    return Result<T>.success(data: model)
                } else {
                    return Result<T>.failure(message: "Decode Response Failure")
                }
            } else {
                let model = try decoder.decode(type.self, from: data)
                return Result<T>.success(data: model)
            }
        }
        catch  {
            print(error)
            return Result<T>.error(err: NetworkError.jsonDecodeError)
            
        }
    }
}

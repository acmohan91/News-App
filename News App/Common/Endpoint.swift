//
//  Endpoint.swift
//  News App
//
//  Created by Mohan AC on 13/02/22.
//

import Foundation

protocol EndPointType {
    var urlPath: String { get }
    var httpMethod: String { get }
}

enum Content: EndPointType {
    case getNews
    case getLikes(newsArticleId: String)
    case getComments(newsArticleId: String)
    
    var urlPath: String {
        switch  self {
        case .getNews:
            return "https://newsapi.org/v2/top-headlines" + "?country=us" + "&apiKey=a10b251bcc114018a291f35a1a344937"
        case .getLikes(let id):
            return "https://cn-news-info-api.herokuapp.com/likes/" + id
        case .getComments(let id):
            return "https://cn-news-info-api.herokuapp.com/comments/" + id
        }
    }
    
    var httpMethod: String {
        switch  self {
        case .getNews, .getLikes, .getComments:
            return "GET"
        }
    }
}

//
//  News.swift
//  News App
//
//  Created by Mohan AC on 13/02/22.
//

import Foundation

struct News: Decodable {
    let source: Source?
    let author: String?
    var title: String?
    var description: String?
    var url: String?
    let urlToImage: String?
    var publishedAt: String?
    let content: String?
    var likes: Int?
    var comments: Int?
}

struct Source: Codable {
    let id: String?
    let name: String?
}

struct likes: Codable {
    let likes: Int?
}

struct comments: Codable {
    let comments: Int?
}

//
//  News.swift
//  Hospital
//
//  Created by Simone Montalto on 23/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import Foundation

class News {
    var author: String
    var title: String
    var description: String
    var urlSite: URL
    var urlImage: URL
    var publishedAt: String
    
    init(author: String, title: String, description: String, urlSite: URL, urlImage: URL, publishedAt: String) {
        self.author = author
        self.title = title
        self.description = description
        self.urlSite = urlSite
        self.urlImage = urlImage
        self.publishedAt = publishedAt
    }
    
}

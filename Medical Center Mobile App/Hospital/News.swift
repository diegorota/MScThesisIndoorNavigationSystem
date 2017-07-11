//
//  News.swift
//  Hospital
//
//  Created by Simone Montalto on 23/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import Foundation
import UIKit

class News {
    var author: String
    var title: String
    var description: String
    var urlSite: URL
    var postImage: UIImage
    var publishedAt: String
    
    init(author: String, title: String, description: String, urlSite: URL, postImage: UIImage, publishedAt: String) {
        self.author = author
        self.title = title
        self.description = description
        self.urlSite = urlSite
        self.postImage = postImage
        self.publishedAt = publishedAt
    }
    
}

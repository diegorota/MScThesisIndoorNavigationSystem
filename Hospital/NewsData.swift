//
//  NewsData.swift
//  Hospital
//
//  Created by Simone Montalto on 23/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import Foundation
import UIKit

class NewsData {
    
    static var newsList: [News]?
    
    static func getData(refreshData: Bool) -> [News]? {
        if newsList == nil || refreshData {
            getNewsData()
        
            return newsList
        } else {
            
            return newsList
        }
    }
    
    static func getNewsData() {
        let urlString = "https://newsapi.org/v1/articles?source=new-scientist&sortBy=top&apiKey=60a1be8a925c4dffa185aa93bb9e451b"
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                let json = JSON(data: data)
                
                if json["status"].stringValue == "ok" {
                    parse(json: json["articles"])
                }
            }
        }
    }
    
    static func parse(json: JSON) {
        newsList = [News]()
        for news in json.arrayValue {
            let newsDetail = News(author: news["author"].stringValue, title: news["title"].stringValue, description: news["description"].stringValue, urlSite: URL(string: news["url"].stringValue)!, urlImage: URL(string: news["urlToImage"].stringValue)!, publishedAt: news["publishedAt"].stringValue)
            newsList?.append(newsDetail)
        }
    }
    
}

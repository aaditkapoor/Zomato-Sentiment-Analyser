//
//  URLCreator.swift
//  ZomatoAnalyser
//
//  Created by Aadit Kapoor on 6/17/17.
//  Copyright © 2017 Aadit Kapoor. All rights reserved.
//

import Foundation

let API_KEY = "dc8442573c7f7f06411cc5c93be0465e"

enum Command:String {
    case search = "https://developers.zomato.com/api/v2.1/search?q="
    case reviews = "https://developers.zomato.com/api/v2.1/reviews?res_id="
}


    func create_search_url(q:String) -> String? {
        let escapedString = q.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)

        var url:String?
        if let e = escapedString {
        url = Command.search.rawValue + e
            return url
        }
        else {
            debugPrint("Optional came in q")
            return nil
        }
        
    }
    
    func create_review_url(resID:String) -> String {
        let url = Command.reviews.rawValue + resID
        return url
    }

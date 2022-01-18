//
//  MatchupData.swift
//  SportsApp_finalproject
//
//  Created by Doherty, Benjamin J on 11/25/19.
//  Copyright © 2019 Doan, Douglas T. All rights reserved.
//


import UIKit

protocol matchupDataProtocol
{
    func responseDataHandler(data:NSDictionary)
    func responseError(message:String)
}

class MatchupData {
    private let urlSession = URLSession.shared

    private let urlPathBase = ["http://api.sportradar.us/nba/trial/v7/en/games/","/boxscore.json?api_key=5hjf957xyqr2w4cdf5mnk8w4"]
    private var dataTask:URLSessionDataTask? = nil

    var delegate:matchupDataProtocol? = nil
    
    init() {}
    
    func getData(MatchupData: String) {
        let urlPath = urlPathBase[0] + MatchupData + urlPathBase[1]
        let url:NSURL? = NSURL(string: urlPath)
        
        let dataTask = self.urlSession.dataTask(with: url! as URL) { (data, response, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    if jsonResult != nil {
                        
                        self.delegate?.responseDataHandler(data: jsonResult!)
                        
                    }
                } catch {
                    print("nil data")
                }
            }
        }
        dataTask.resume()
    }
}

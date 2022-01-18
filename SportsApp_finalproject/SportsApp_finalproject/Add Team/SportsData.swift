//
//  SportsData.swift
//  SportsApp_finalproject
//
//  Created by Doherty, Benjamin J on 11/18/19.
//  Copyright © 2019 Doan, Douglas T. All rights reserved.
//

import UIKit

protocol sportsDataProtocol
{
    func responseDataHandler(data:NSDictionary)
    func responseError(message:String)
}

class SportsData {
    private let urlSession = URLSession.shared
    
    private let urlPathBase = "http://api.sportradar.us/nba/trial/v7/en/games/2019/REG/schedule.json?api_key=5hjf957xyqr2w4cdf5mnk8w4"
    private var dataTask:URLSessionDataTask? = nil

    var delegate:sportsDataProtocol? = nil
    
    init() {}
    
    func getData() {
        let urlPath = self.urlPathBase
        //urlPath = urlPath + SportsData
        let url:NSURL? = NSURL(string: urlPath)
        
        let dataTask = self.urlSession.dataTask(with: url! as URL) { (data, response, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    if jsonResult != nil {
                        let jsonData = jsonResult!
                        
                        if jsonData != nil {
                            self.delegate?.responseDataHandler(data: jsonResult!)
                            //print("yay")
                        } else {
                            self.delegate?.responseError(message: "")
                            //print("nay")
                        }
                    }
                } catch {
                    print("nil data")
                }
            }
        }
        dataTask.resume()
    }
}

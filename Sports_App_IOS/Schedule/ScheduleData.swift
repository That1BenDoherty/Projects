//
//  ScheduleData.swift
//  SportsApp_finalproject
//
//  Created by Doherty, Benjamin J on 11/18/19.
//  Copyright © 2019 Doan, Douglas T. All rights reserved.
//

import UIKit

protocol scheduleDataProtocol
{
    func responseDataHandler(data:NSArray)
    func responseError(message:String)
}

class ScheduleData {
    private let urlSession = URLSession.shared

    private let urlPathBase = ["http://api.sportradar.us/nba/trial/v7/en/games/","/schedule.json?api_key=5hjf957xyqr2w4cdf5mnk8w4"]
    private var dataTask:URLSessionDataTask? = nil

    var delegate:scheduleDataProtocol? = nil
    
    init() {}
    
    func getData(ScheduleData: Date) {
        let dateForm: DateFormatter = DateFormatter()
        dateForm.dateFormat = "yyyy/MM/dd"
        let date = dateForm.string(from: ScheduleData)
        
        let urlPath = self.urlPathBase[0] + date + self.urlPathBase[1]
        let url:NSURL? = NSURL(string: urlPath)
        
        let dataTask = self.urlSession.dataTask(with: url! as URL) { (data, response, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    if jsonResult != nil {
                        let jsonData = jsonResult!["games"]! as! NSArray
                        self.delegate?.responseDataHandler(data: jsonData)

                        
                    }
                } catch {
                    print("nil data")
                }
            }
        }
        dataTask.resume()
    }
}

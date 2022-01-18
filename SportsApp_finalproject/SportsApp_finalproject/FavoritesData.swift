//
//  FavoritesData.swift
//  SportsApp_finalproject
//
//  Created by Doherty, Benjamin J on 12/4/19.
//  Copyright © 2019 Doan, Douglas T. All rights reserved.
//

//Test

import UIKit

open class FavoritesData {
    private let urlSession = URLSession.shared

    private let urlPathBase = ["http://api.sportradar.us/nba/trial/v7/en/games/","/boxscore.json?api_key=5hjf957xyqr2w4cdf5mnk8w4"]
    private var dataTask:URLSessionDataTask? = nil
    
    init() {}
    
    func getYesterdayData(_ parameters: Array<String>, completionHandler: @escaping (_ result: Games,_ error: String) -> Void) {
        let urlPath = urlPathBase[0] + parameters[0] + urlPathBase[1]
        let url:NSURL? = NSURL(string: urlPath)
        
        let dataTask = self.urlSession.dataTask(with: url! as URL) { (data, response, error) -> Void in
            if error != nil {
                let errorMessage = error!
            } else {
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    if jsonResult != nil {
    
                        
                        let data = jsonResult!
                        
                        let status = data["status"]! as! String
                        let id = data["id"]! as! String
                        
                        // If the games happened will get more info like score each quarter and key players, otherwise will just show two teams and gametime
                        if status == "closed" {
                            let home = data["home"]! as! NSDictionary
                            let homeAlias = home["alias"]! as! String
                            let homeName = home["name"]! as! String
                            
                            let away = data["away"]! as! NSDictionary
                            let awayAlias = away["alias"]! as! String
                            let awayName = away["name"]! as! String
                            
                            // scoring data
                            let HomePoints = home["points"] as! Int
                            let HomeScoring = home["scoring"] as! NSArray
                            var HomeQuarterlyPoints = [Int]()
                                        
                            let AwayPoints = away["points"] as! Int
                            let AwayScoring = away["scoring"] as! NSArray
                            var AwayQuarterlyPoints = [Int]()
                            
                            let day = data["scheduled"]! as! String; let time = self.jsonConvert(str: day)
                            let homelogo = URL(string: "https://www.nba.com/.element/img/1.0/teamsites/logos/teamlogos_500x500/"+homeAlias.lowercased()+".png")!
                            let awaylogo = URL(string: "https://www.nba.com/.element/img/1.0/teamsites/logos/teamlogos_500x500/"+awayAlias.lowercased()+".png")!
                            
                            let newGame = Games(id: id, home: homeName, away: awayName, home_score: HomePoints, away_score: AwayPoints, time: time, homeLogo: homelogo, awayLogo: awaylogo)
        
                            completionHandler(newGame!,"")
                        }
                    }
                } catch {
                    print("nil data")
                }
            }
        }
        dataTask.resume()
    }
    
    func getTodayData(_ parameters: Array<String>, completionHandler: @escaping (_ result: Games,_ error: String) -> Void) {
    let urlPath = urlPathBase[0] + parameters[0] + urlPathBase[1]
    let url:NSURL? = NSURL(string: urlPath)
    
    let dataTask = self.urlSession.dataTask(with: url! as URL) { (data, response, error) -> Void in
        if error != nil {
            let errorMessage = error!
        } else {
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                if jsonResult != nil {
                        
                        let data = jsonResult!
                        
                        let status = data["status"]! as! String
                        let id = data["id"]! as! String
                    
                        let home = data["home"]! as! NSDictionary
                        let homeAlias = home["alias"]! as! String
                        let homeName = home["name"]! as! String
                        
                        let away = data["away"]! as! NSDictionary
                        let awayAlias = away["alias"]! as! String
                        let awayName = away["name"]! as! String
                        
                        let day = data["scheduled"]! as! String; let time = self.jsonConvert(str: day)
                        let homelogo = URL(string: "https://www.nba.com/.element/img/1.0/teamsites/logos/teamlogos_500x500/"+homeAlias.lowercased()+".png")!
                        let awaylogo = URL(string: "https://www.nba.com/.element/img/1.0/teamsites/logos/teamlogos_500x500/"+awayAlias.lowercased()+".png")!
                        
                        let newGame = Games(id: id, home: homeName, away: awayName, home_score: 0, away_score: 0, time: time, homeLogo: homelogo, awayLogo: awaylogo)
                        
                        completionHandler(newGame!,"")
            
                    }
                } catch {
                    print("nil data")
                }
            }
        }
        dataTask.resume()
    }
    
    // Takes json's funcky date structure and puts it into day, hours, and mins
    func jsonConvert(str: String) -> String {
        let str = String(str.dropLast(6))
    
        let dateFor: DateFormatter = DateFormatter()
        dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let yourDate: NSDate? = dateFor.date(from: str) as NSDate?
    
        let dateFormat: DateFormatter = DateFormatter()
        dateFormat.locale = Locale(identifier: "en_US"); dateFormat.timeZone = TimeZone(secondsFromGMT: 43200)
        dateFormat.setLocalizedDateFormatFromTemplate("MMMd hh:mm a")
        let convertedDate = dateFormat.string(from: yourDate! as Date)
        return convertedDate
    }

}


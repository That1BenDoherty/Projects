//
//  MatchupViewController.swift
//  SportsApp_finalproject
//
//  Created by Doan, Douglas T on 11/11/19.
//  Copyright © 2019 Doan, Douglas T. All rights reserved.
//

import UIKit

class MatchupViewController: UIViewController, matchupDataProtocol {

    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var scoringView: UIView!
    @IBOutlet weak var keyView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var gameTime: UILabel!
    
    @IBOutlet weak var homeLogo: UIImageView!
    @IBOutlet weak var homeAbbrLabel: UILabel!
    @IBOutlet weak var homeNameLabel: UILabel!
    @IBOutlet weak var awayLogo: UIImageView!
    @IBOutlet weak var awayAbbrLabel: UILabel!
    @IBOutlet weak var awayNameLabel: UILabel!
    
    @IBOutlet weak var homeAbbr: UILabel!
    @IBOutlet weak var q1home: UILabel!
    @IBOutlet weak var q2home: UILabel!
    @IBOutlet weak var q3home: UILabel!
    @IBOutlet weak var q4home: UILabel!
    @IBOutlet weak var finalHome: UILabel!
    
    @IBOutlet weak var awayAbbr: UILabel!
    @IBOutlet weak var q1away: UILabel!
    @IBOutlet weak var q2away: UILabel!
    @IBOutlet weak var q3away: UILabel!
    @IBOutlet weak var q4away: UILabel!
    @IBOutlet weak var finalAway: UILabel!
    
    @IBOutlet weak var player1: UILabel!
    @IBOutlet weak var pts1: UILabel!
    @IBOutlet weak var reb1: UILabel!
    @IBOutlet weak var ast1: UILabel!
    @IBOutlet weak var stl1: UILabel!
    @IBOutlet weak var blk1: UILabel!
    
    @IBOutlet weak var player2: UILabel!
    @IBOutlet weak var pts2: UILabel!
    @IBOutlet weak var reb2: UILabel!
    @IBOutlet weak var ast2: UILabel!
    @IBOutlet weak var stl2: UILabel!
    @IBOutlet weak var blk2: UILabel!
    
    var matchup = MatchupData()

    var game: String = "" // Will give us the spesific gameid so we can search for the data
    var time: String = "" // gives us time for the game cause it's annoying converting from the json data

    var thisDate = Date()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.matchup.delegate = self
        self.matchup.getData(MatchupData: game)
        
        scoringView.layer.borderWidth = 2
        scoringView.layer.cornerRadius = 10
        keyView.layer.borderWidth = 2
        keyView.layer.cornerRadius = 10
    }
    
    // MARK: Actions
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // Gets data and dislays it
    func responseDataHandler(data: NSDictionary) {
        
        let status = data["status"]! as! String
        let day = data["scheduled"]! as! String; let date = self.jsonConvert(str: day)
        
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
            
            for i in 0...(AwayScoring.count - 1) {
                
                let HomeQuarter = HomeScoring[i] as! NSDictionary
                let HomeQpoints = HomeQuarter["points"] as! Int
                HomeQuarterlyPoints.append(HomeQpoints)
                
                let AwayQuarter = AwayScoring[i] as! NSDictionary
                let AwayQpoints = AwayQuarter["points"] as! Int
                AwayQuarterlyPoints.append(AwayQpoints)
            }
            
            
            let HQ1 = HomeQuarterlyPoints[0]
            let HQ2 = HomeQuarterlyPoints[1] + HQ1
            let HQ3 = HomeQuarterlyPoints[2] + HQ2
            let HQ4 = HomeQuarterlyPoints[3] + HQ3
            
            let AQ1 = AwayQuarterlyPoints[0]
            let AQ2 = AwayQuarterlyPoints[1] + AQ1
            let AQ3 = AwayQuarterlyPoints[2] + AQ2
            let AQ4 = AwayQuarterlyPoints[3] + AQ3

            
            // Leading Player on each side
            
            let HomeLeaders = home["leaders"] as! NSDictionary
            let HomePointsLeader = HomeLeaders["points"] as! NSArray
            let HomePointsLeaderInfo = HomePointsLeader[0] as! NSDictionary
            
            let HomeLeaderName = HomePointsLeaderInfo["full_name"] as! String
            let HomeLeaderNumber = HomePointsLeaderInfo["jersey_number"]!
            let HomeLeaderPosition = HomePointsLeaderInfo["primary_position"] as! String
            
            let HomeLeaderStats = HomePointsLeaderInfo["statistics"] as! NSDictionary
            let HomeLeaderPoints = HomeLeaderStats["points"] as! Int
            let HomeLeaderRebounds = HomeLeaderStats["rebounds"] as! Int
            let HomeLeaderAssists = HomeLeaderStats["assists"] as! Int
            let HomeLeaderSteals = HomeLeaderStats["steals"] as! Int
            let HomeLeaderBlocks = HomeLeaderStats["blocks"] as! Int
            
            let AwayLeaders = away["leaders"] as! NSDictionary
            let AwayPointsLeader = AwayLeaders["points"] as! NSArray
            let AwayPointsLeaderInfo = AwayPointsLeader[0] as! NSDictionary
            
            let AwayLeaderName = AwayPointsLeaderInfo["full_name"] as! String
            let AwayLeaderNumber = AwayPointsLeaderInfo["jersey_number"]!
            let AwayLeaderPosition = AwayPointsLeaderInfo["primary_position"] as! String
            
            let AwayLeaderStats = AwayPointsLeaderInfo["statistics"] as! NSDictionary
            let AwayLeaderPoints = AwayLeaderStats["points"] as! Int
            let AwayLeaderRebounds = AwayLeaderStats["rebounds"] as! Int
            let AwayLeaderAssists = AwayLeaderStats["assists"] as! Int
            let AwayLeaderSteals = AwayLeaderStats["steals"] as! Int
            let AwayLeaderBlocks = AwayLeaderStats["blocks"] as! Int
            
            let homelogo = URL(string: "https://www.nba.com/.element/img/1.0/teamsites/logos/teamlogos_500x500/"+homeAlias.lowercased()+".png")!
            let awaylogo = URL(string: "https://www.nba.com/.element/img/1.0/teamsites/logos/teamlogos_500x500/"+awayAlias.lowercased()+".png")!
            DispatchQueue.main.async() {
                self.titleLabel.text = homeAlias + " @ " + awayAlias
                self.gameTime.isHidden = true; self.timeLabel.isHidden = true; self.bottomView.isHidden = false
                
                self.homeLogo.downloadImage(from: homelogo)
                self.homeAbbrLabel.text = homeAlias
                self.homeNameLabel.text = homeName
                
                self.awayLogo.downloadImage(from: awaylogo)
                self.awayAbbrLabel.text = awayAlias
                self.awayNameLabel.text = awayName
                
                self.homeAbbr.text = homeAlias
                self.q1home.text = String(HQ1)
                self.q2home.text = String(HQ2)
                self.q3home.text = String(HQ3)
                self.q4home.text = String(HQ4)
                self.finalHome.text = String(HomePoints)
                
                self.awayAbbr.text = awayAlias
                self.q1away.text = String(AQ1)
                self.q2away.text = String(AQ2)
                self.q3away.text = String(AQ3)
                self.q4away.text = String(AQ4)
                self.finalAway.text = String(AwayPoints)
                
                self.player1.text = HomeLeaderName
                self.pts1.text = String(HomeLeaderPoints)
                self.reb1.text = String(HomeLeaderRebounds)
                self.ast1.text = String(HomeLeaderAssists)
                self.stl1.text = String(HomeLeaderSteals)
                self.blk1.text = String(HomeLeaderBlocks)
                
                self.player2.text = AwayLeaderName
                self.pts2.text = String(AwayLeaderPoints)
                self.reb2.text = String(AwayLeaderRebounds)
                self.ast2.text = String(AwayLeaderAssists)
                self.stl2.text = String(AwayLeaderSteals)
                self.blk2.text = String(AwayLeaderBlocks)
                
            }
            
        } else{ // don't have score data
            let home = data["home"]! as! NSDictionary
            let homeAlias = home["alias"]! as! String
            let homeName = home["name"]! as! String
            
            let away = data["away"]! as! NSDictionary
            let awayAlias = away["alias"]! as! String
            let awayName = away["name"]! as! String
            
            
            let homelogo = URL(string: "https://www.nba.com/.element/img/1.0/teamsites/logos/teamlogos_500x500/"+homeAlias.lowercased()+".png")!
            let awaylogo = URL(string: "https://www.nba.com/.element/img/1.0/teamsites/logos/teamlogos_500x500/"+awayAlias.lowercased()+".png")!
            DispatchQueue.main.async() {
                self.titleLabel.text = homeAlias + " vs " + awayAlias
                
                self.homeLogo.downloadImage(from: homelogo)
                self.homeAbbrLabel.text = homeAlias
                self.homeNameLabel.text = homeName
                
                self.awayLogo.downloadImage(from: awaylogo)
                self.awayAbbrLabel.text = awayAlias
                self.awayNameLabel.text = awayName
                
                self.gameTime.isHidden = false; self.timeLabel.isHidden = false; self.bottomView.isHidden = true
                self.timeLabel.text = date
            }
        }
        
    }
    
    func responseError(message: String) {
        print(message)
    }
    
    func jsonConvert(str: String) -> String {
        let str = String(str.dropLast(6))
        
        let dateFor: DateFormatter = DateFormatter()
        dateFor.dateFormat = "yyy-MM-dd'T'HH:mm:ss"
        
        let yourDate: NSDate? = dateFor.date(from: str) as NSDate?
        
        let dateFormat: DateFormatter = DateFormatter()
        dateFormat.locale = Locale(identifier: "en_US"); dateFormat.timeZone = TimeZone(secondsFromGMT: 43200)
        dateFormat.setLocalizedDateFormatFromTemplate("MMMd hh:mm a")
        let convertedDate = dateFormat.string(from: yourDate! as Date)
        return convertedDate
    }
    

}

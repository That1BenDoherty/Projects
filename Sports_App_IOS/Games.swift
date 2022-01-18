//
//  Games.swift
//  SportsApp_finalproject
//
//  Created by Doherty, Benjamin J on 11/18/19.
//  Copyright © 2019 Doan, Douglas T. All rights reserved.
//

import UIKit

class Games {
    
    var id: String
    var home: String
    var away: String
    var home_score: Int?
    var away_score: Int?
    var time: String
    var homeLogo: URL
    var awayLogo: URL
    
    //var home_icon: UIImage?
    
    //MARK: Initialization
    
    init?(id:String, home: String, away: String, home_score: Int?, away_score: Int?, time: String, homeLogo: URL, awayLogo: URL) {
        
        // Initialize stored properties.
        self.id = id
        self.home = home
        self.away = away
        self.home_score = home_score
        self.away_score = away_score
        self.time = time
        self.homeLogo = homeLogo
        self.awayLogo = awayLogo

        
    }
}

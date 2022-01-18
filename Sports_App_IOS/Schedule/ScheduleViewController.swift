//
//  CalendarViewController.swift
//  SportsApp_finalproject
//
//  Created by Doan, Douglas T on 11/11/19.
//  Copyright © 2019 Doan, Douglas T. All rights reserved.
//

import UIKit
import CoreData

class ScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, scheduleDataProtocol {
    
    @IBOutlet weak var tableView:UITableView!
    // View of 5 dates
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var tapView1: UIView!
    @IBOutlet weak var tapView2: UIView!
    @IBOutlet weak var tapView3: UIView!
    @IBOutlet weak var tapView4: UIView!
    
    let transition = CircularTransition()
    
    var schedule = ScheduleData()
    var games = [Games]()  // Array of all games
    var favTeams: [NSManagedObject] = [] // List of fav teams
    var width = CGFloat()
    
    private var thisDate = Date() // will be changed to whichever date is selected
    private let today = Date() // always todays date
    
    // Load core data for fav teams
    override func viewWillAppear(_ animated: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Team")
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            try fetchedResults = managedContext.fetch(fetchRequest) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unable to fetch \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        if let results = fetchedResults {
            favTeams = results
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.schedule.delegate = self
        width = (view.frame.width-34)/5
        
        tableView.reloadData()
        setUpDates()
        
        self.schedule.getData(ScheduleData: thisDate)
    }
    
    
    // MARK: - Day Stack View
    
    // Creates labels for buttons around the day selected
    func setUpDates() {
        let height = buttonView.frame.height
        for x in 1...9 {
            let button = buttonView.viewWithTag(x) as? UIButton
            button!.frame = CGRect(x: width * CGFloat(x-3), y: 0, width: width, height: height)
        }
        tapView1.frame = CGRect(x: 0, y: 0, width: width, height: buttonView.frame.height); tapView2.frame = CGRect(x: width, y: 0, width: width, height: height);tapView3.frame = CGRect(x: width * CGFloat(3), y: 0, width: width, height: height) ; tapView4.frame = CGRect(x: width * CGFloat(4), y: 0, width: width, height: height)
        
        
        
        let maxDayIndex = 8
        
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
        
        for i in -maxDayIndex/2...maxDayIndex/2 {
            if let date = calendar.date(byAdding: .day, value: -i, to: thisDate), let button = buttonView.viewWithTag(maxDayIndex/2 - i+1) as? UIButton {
                if formatter.string(from: date) == formatter.string(from: today) { button.setTitle("TODAY", for: .normal)
                } else { button.setTitle(formatter.string(from: date), for: .normal) }
            }
        }
    }
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CalendarTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ScheduleTableViewCell else {fatalError("The dequed cell is not an instance of ScheduleTableViewCell.")}
        
        // Displays data for all games found
        let game = games[indexPath.row]
        
        cell.team1Label.text = game.home
        cell.team2Label.text = game.away
        cell.team1Image.downloadImage(from: game.homeLogo)
        cell.team2Image.downloadImage(from: game.awayLogo)
        
        // If there are reported scores show them, otherwise show when the game will be
        if game.home_score != nil && game.away_score != nil {
            cell.timeLabel.isHidden = true
            cell.score1.isHidden = false; cell.score2.isHidden = false
            cell.score1.text = String(game.home_score!); cell.score2.text = String(game.away_score!)
        } else {
            cell.timeLabel.isHidden = false
            cell.score1.isHidden = true; cell.score2.isHidden = true
            cell.timeLabel.text = game.time
        }
        
        for team in favTeams {
            let name = team.value(forKeyPath:"name") as! String
            if name == game.home { cell.team1Label.textColor = UIColor.systemOrange}
            else {cell.team1Label.textColor = UIColor.black }
            if name == game.away { cell.team2Label.textColor = UIColor.systemOrange}
            else {cell.team2Label.textColor = UIColor.black }
        }
    
        return cell
    }
    
    // MARK: - Actions
    
    // Will change date and data displayed to date from the button
    @IBAction func button_neg2(_ sender: UITapGestureRecognizer) {
        thisDate = Calendar.current.date(byAdding: Calendar.Component.day, value: -2, to: thisDate)!
        slideIn(self.buttonView, true, thisDate, true)
        games.removeAll()
        self.schedule.getData(ScheduleData: thisDate)
    }
    
    @IBAction func button_neg1(_ sender: UITapGestureRecognizer) {
        thisDate = Calendar.current.date(byAdding: Calendar.Component.day, value: -1, to: thisDate)!
        slideIn(self.buttonView, true, thisDate)
        games.removeAll()
        self.schedule.getData(ScheduleData: thisDate)
    }
    @IBAction func button_plus1(_ sender: UITapGestureRecognizer) {
        thisDate = Calendar.current.date(byAdding: Calendar.Component.day, value: 1, to: thisDate)!
        slideIn(self.buttonView, false, thisDate)
        games.removeAll()
        self.schedule.getData(ScheduleData: thisDate)
    }
    @IBAction func button_plus2(_ sender: UITapGestureRecognizer) {
        thisDate = Calendar.current.date(byAdding: Calendar.Component.day, value: 2, to: thisDate)!
        slideIn(self.buttonView, false, thisDate, true)
        games.removeAll()
        self.schedule.getData(ScheduleData: thisDate)
    }
    
    // Animate buttons to side to date selected
    func slideIn(_ view: UIView,_ left: Bool,_ date: Date,_ doub: Bool = false) {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
        
        var sign: Int; if left {sign = 1} else {sign = -1 }
        var mult: Int; if doub {mult = 2} else {mult = 1}
        let widthInt = Int(width)
        UIView.animate(withDuration: 0.5,
                    delay: 0,
                    options: .curveEaseInOut,
                    animations: {
                        // Prevents spamming button while the animation is happening
                        self.tapView1.isHidden = true; self.tapView2.isHidden = true; self.tapView3.isHidden = true; self.tapView4.isHidden = true
                        view.viewWithTag(1)?.isHidden = false; view.viewWithTag(2)?.isHidden = false; view.viewWithTag(8)?.isHidden = false; view.viewWithTag(9)?.isHidden = false
                        for indx in 1...9 { // Moving all buttons
                            let button = view.viewWithTag(indx) as! UIButton
                            button.center.x += CGFloat(sign * mult * widthInt)}},
                    completion: {finished in
                        // Once animation is done, send front button to back or vise versa and change it's title, change which button is blue, and changes all the tags to be in order again
                        if left {
                            let day = calendar.date(byAdding: .day, value: -4, to: date)
                            let dayAfter = calendar.date(byAdding: .day, value: -3, to: date)
                            let oldBlue = view.viewWithTag(5) as! UIButton; oldBlue.setTitleColor(UIColor.darkText, for: .normal)
                            let newBlue = view.viewWithTag(5-mult) as! UIButton; newBlue.setTitleColor(UIColor.link, for: .normal)
                            let button = view.viewWithTag(9) as! UIButton
                            var button2 = UIButton(); if doub {button2 = view.viewWithTag(8) as! UIButton
                                for indx in 1...7 {view.viewWithTag(8-indx)?.tag = 10-indx}; button.tag = 2; button2.tag = 1
                                button.center.x = -self.width/2; button2.center.x = -(3 * self.width / 2)
                            } else {
                                for indx in 1...8 {view.viewWithTag(9-indx)?.tag = 10-indx}; button.tag = 1
                                button.center.x = -(3 * self.width / 2)
                            }
                            
                            if formatter.string(from: day!) == formatter.string(from: self.today) {
                                button.setTitle("TODAY", for: .normal)
                                if doub {button2.setTitle("TODAY", for: .normal); button.setTitle(formatter.string(from: dayAfter!), for: .normal)}
                            } else if doub && formatter.string(from: dayAfter!) == formatter.string(from: self.today){
                                button.setTitle("TODAY", for: .normal); button2.setTitle(formatter.string(from: day!), for: .normal)
                            } else if doub { button2.setTitle(formatter.string(from: day!), for: .normal)
                                button.setTitle(formatter.string(from: dayAfter!), for: .normal)
                            }else { button.setTitle(formatter.string(from: day!), for: .normal) }
                            
                            
                        } else {
                            let day = calendar.date(byAdding: .day, value: 4, to: date)
                            let dayBefore = calendar.date(byAdding: .day, value: 3, to: date)
                            let oldBlue = view.viewWithTag(5) as! UIButton; oldBlue.setTitleColor(UIColor.darkText, for: .normal)
                            let newBlue = view.viewWithTag(5+mult) as! UIButton; newBlue.setTitleColor(UIColor.link, for: .normal)
                            let button = view.viewWithTag(1) as! UIButton
                            var button2 = UIButton(); if doub {button2 = view.viewWithTag(2) as! UIButton
                                for indx in 3...9 {view.viewWithTag(indx)?.tag = indx-2}; button.tag = 8; button2.tag = 9
                                button.center.x = (11 * self.width/2) ; button2.center.x = (13 * self.width/2)
                            } else {
                                for indx in 2...9 {view.viewWithTag(indx)?.tag = indx-1}; button.tag = 9
                                button.center.x = (13 * self.width/2)
                            }
                                
                            if formatter.string(from: day!) == formatter.string(from: self.today) {
                                button.setTitle("TODAY", for: .normal)
                                if doub {button2.setTitle("TODAY", for: .normal); button.setTitle(formatter.string(from: dayBefore!), for: .normal)}
                            } else if doub && formatter.string(from: dayBefore!) == formatter.string(from: self.today){
                                button.setTitle("TODAY", for: .normal); button2.setTitle(formatter.string(from: day!), for: .normal)
                            } else if doub { button2.setTitle(formatter.string(from: day!), for: .normal)
                            button.setTitle(formatter.string(from: dayBefore!), for: .normal)
                            } else { button.setTitle(formatter.string(from: day!), for: .normal) }
                        }
                        self.tapView1.isHidden = false; self.tapView2.isHidden = false; self.tapView3.isHidden = false; self.tapView4.isHidden = false
                        view.viewWithTag(1)?.isHidden = true; view.viewWithTag(2)?.isHidden = true; view.viewWithTag(8)?.isHidden = true; view.viewWithTag(9)?.isHidden = true
        })
    }
    
    // Grabbing date selected from calender view, then displaying data from that day
    @IBAction func unwindToSchedule(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CalendarMonthViewController, var date: Date = (Date()){
            DispatchQueue.main.async() { date = sourceViewController.thisDate!
                self.thisDate = date
                self.games.removeAll()
                self.schedule.getData(ScheduleData: self.thisDate)
                self.setUpDates()
            }
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.transitionMode = .present
        transition.startingPoint = tableView.center
        transition.circleColor = tableView.backgroundColor!
        
        return transition
        
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.transitionMode = .dismiss
        transition.startingPoint = tableView.center
        transition.circleColor = tableView.backgroundColor!
        
        return transition
    }
    
    // Sending data to matchup when a row is hit
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "matchups":
            let contentViewController = segue.destination as? MatchupViewController
            contentViewController!.transitioningDelegate = self
            contentViewController!.modalPresentationStyle = .custom
                        
            if let selectedRow = sender as? ScheduleTableViewCell {
                let indexPath = tableView.indexPath(for: selectedRow)!
                if contentViewController != nil && !games.isEmpty {
                    contentViewController!.game = games[indexPath[1]].id
                    contentViewController!.time = games[indexPath[1]].time
                }
            }
            
        case "favs":
            let contentViewController = segue.destination as? MatchupViewController

            if let selectedRow = sender as? ScheduleTableViewCell {
                let indexPath = tableView.indexPath(for: selectedRow)!
                if contentViewController != nil {
                    contentViewController!.game = games[indexPath[1]].id
                    contentViewController!.time = games[indexPath[1]].time
                }
            }
        case "calendar":
            let nothing = 0 // Do nothing
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    
    // MARK: - Schedule Data Protocol
    
    // Taking all the info from each game and putting it in a class, then adding it to our list of games for the day
    func responseDataHandler(data: NSArray) {
        for d in data {
            
            let game = d as! NSDictionary
            let id = game["id"]! as! String
            let away = game["away"]! as! NSDictionary
            let away_name = away["name"]! as! String
            let home = game["home"]! as! NSDictionary
            let home_name = home["name"]! as! String
            var away_points: Int?; var home_points: Int?
            if game["away_points"] != nil {
                away_points = game["away_points"]! as? Int
                home_points = game["home_points"]! as? Int
            } else { }
            let day = game["scheduled"]! as! String; let time = jsonConvert(str: day)
            
            let awayAlias = away["alias"]! as! String; let homeAlias = home["alias"]! as! String
            let awaylogo = URL(string: "https://www.nba.com/.element/img/1.0/teamsites/logos/teamlogos_500x500/"+awayAlias.lowercased()+".png")!
            let homelogo = URL(string: "https://www.nba.com/.element/img/1.0/teamsites/logos/teamlogos_500x500/"+homeAlias.lowercased()+".png")!

            let newGame = Games(id: id, home: home_name, away: away_name, home_score: home_points, away_score: away_points, time: time, homeLogo: homelogo, awayLogo: awaylogo)!
            games.append(newGame)
                
            DispatchQueue.main.async() {
                self.tableView.reloadData()
            }
        }
    }
    
    func responseError(message: String) {
        print(message)
    }
    
    // Takes json's funcky date structure and puts it into hours and mins
    func jsonConvert(str: String) -> String {
        let str = String(str.dropLast(6))
        
        let dateFor: DateFormatter = DateFormatter()
        dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let yourDate: NSDate? = dateFor.date(from: str) as NSDate?
        
        let dateFormat: DateFormatter = DateFormatter()
        dateFormat.locale = Locale(identifier: "en_US"); dateFormat.timeZone = TimeZone(secondsFromGMT: 43200); dateFormat.timeStyle = .short
        let convertedDate = dateFormat.string(from: yourDate! as Date)
        return convertedDate
    }

}

// adds onto UIImageView so we can easily download each teams logo
extension UIImageView {
   func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
      URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
   }
   func downloadImage(from url: URL) {
      getData(from: url) {
         data, response, error in
         guard let data = data, error == nil else {
            return
         }
         DispatchQueue.main.async() {
            self.image = UIImage(data: data)
         }
      }
   }
}


extension NSLayoutConstraint {
    override public var description: String {
        let id = identifier ?? "NO ID"
        return "id: \(id), constant: \(constant)"
    }
}

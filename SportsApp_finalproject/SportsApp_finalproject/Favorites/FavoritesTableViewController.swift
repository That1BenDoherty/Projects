//
//  FavoritesTableViewController.swift
//  SportsApp_finalproject
//
//  Created by Doherty, Benjamin J on 11/11/19.
//  Copyright © 2019 Doan, Douglas T. All rights reserved.
//

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController, UIViewControllerTransitioningDelegate {
    
    var favTeams: [NSManagedObject] = [] // Local list of fav teams
    var favTeamGames: Dictionary<String,Dictionary<String,Games>> = [:] // Prepare game data to store
    var favorites = FavoritesData() // Getting data for games
    let today = Calendar.current.date(byAdding: Calendar.Component.hour, value: 3, to: Date())!.getJsonFC() // Dalayed date to make sure a finished game has updated scores
    
    let transition = CircularTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(CustomTeamHeader.self, forHeaderFooterViewReuseIdentifier: "sectionHeader") // Allows us to use our CustomTeamHeader
    }

    override func viewWillAppear(_ animated: Bool) {
        
        getCore() // Get core data, duh
        
        // For all the teams, search through to find most recent game and next game
        var count = 0
        for team in favTeams {
            findGame(num:count)
            count += 1
        }
    }
    
    func findGame(num: Int) { // Accesses game data of most recent game and next game
        let team = favTeams[num]
        let name = team.value(forKeyPath:"name") as! String
        let games = team.value(forKeyPath:"game") as! Array<Array<String>>
        
        // Create an empty dictionary of the team, where we later save game data
        let thisGame = [String: Games]()
        favTeamGames[name] = thisGame
        
        var yesterGame = games[0][0] // store game data of previous index
        for game in games {
            if game[1] > today{ // If game is today or later, save data for that game and game before
                
                favorites.getTodayData([game[0]])  { result, error in
                    self.favTeamGames[name] = ["today": result]
                    DispatchQueue.main.async() {
                        print(self.favTeamGames)
                        self.tableView.reloadData()
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                    self.favorites.getYesterdayData([yesterGame]) { result, error in
                        self.favTeamGames[name] = ["yest": result]
                        DispatchQueue.main.async() {
                            print(self.favTeamGames)
                            self.tableView.reloadData()
                        }
                    }
                }
                
                
                break
                
            } else {
                yesterGame = game[0]
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToFavList(sender: UIStoryboardSegue) { // Get data from adding team and update table
        if let sourceViewController = sender.source as? AddTeamViewController, let results = sourceViewController.favTeam {
            
            favTeams.append(results)
            findGame(num: (favTeams.count - 1))
            tableView.reloadData()
        }
    }
    
    @IBAction func deleteApear(_ gestureRecognizer: UISwipeGestureRecognizer) { // When swiping left make delete button appear on that section
        if gestureRecognizer.state == .ended {
            
            let tagIndex = gestureRecognizer.view!.tag
            let headerView = tableView.viewWithTag(tagIndex) as! CustomTeamHeader
            if headerView.swiped == false { // makes sure you can only swipe once
                UIView.animate(withDuration: 0.3, animations: {
                    headerView.deleteButton.center.x -= 70; headerView.delete.center.x -= 70; headerView.deleteImage.center.x -= 70
                })
                headerView.swiped = true
            }
        }
        
    }
    
    @IBAction func deleteDisapear(_ gestureRecognizer: UISwipeGestureRecognizer) { // When swiping right make delete button disapear on that section
        if gestureRecognizer.state == .ended {
            let tagIndex = gestureRecognizer.view!.tag
            let headerView = tableView.viewWithTag(tagIndex) as! CustomTeamHeader
            if headerView.swiped == true { // makes sure you can only swipe once
                UIView.animate(withDuration: 0.3, animations: {
                    headerView.deleteButton.center.x += 70; headerView.delete.center.x += 70; headerView.deleteImage.center.x += 70
                })
                headerView.swiped = false
            }
        }
    }
    
    @IBAction func buttonPress(sender: UIButton!) { // When hitting delete button, delete that team from core data
        let teamIndex = Int(sender.title(for: .normal)!)!
        
        let headerView = tableView.viewWithTag(teamIndex+1) as! CustomTeamHeader
        headerView.swiped = false
        
        let team = favTeams[teamIndex]
        let teamName = team.value(forKeyPath:"name") as! String
        favTeamGames.removeValue(forKey: teamName)
        favTeams.remove(at: teamIndex)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Team")
        if let result = try? managedContext.fetch(fetchRequest) {
            let object = result[teamIndex] as! NSManagedObject
            managedContext.delete(object)
            do { try managedContext.save()}
            catch let error {print("Could not save \(error.localizedDescription)")}
        }
        
        self.tableView.reloadData()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // Preparing to be sent to matchups
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case "matchups":
            let contentViewController = segue.destination as? MatchupViewController
            contentViewController!.transitioningDelegate = self
            contentViewController!.modalPresentationStyle = .custom
            
            if let selectedRow = sender as? FavoritesTableViewCell {
                let indexPath = tableView.indexPath(for: selectedRow)!
                
                let team = favTeams[indexPath.section]
                let name = team.value(forKeyPath:"name") as! String
                var id = String(); var time = String()
                
                if indexPath.row == 0 {
                    if let yest = favTeamGames[name]!["yest"] {
                        id = yest.id
                        time = yest.time}
                } else {
                    if let today = favTeamGames[name]!["today"] {
                        id = today.id
                        time = today.time }
                }
                
                if contentViewController != nil && !favTeams.isEmpty {
                    contentViewController!.game = id
                    contentViewController!.time = time
                }
            }
        case "add":
            let nothing = 0 // Do nothing
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }

    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return favTeams.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! CustomTeamHeader
        
        // Create a background view in order to change color. Only do that in order to hide delete button
        let backgroudView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 75))
        backgroudView.backgroundColor = headerView.cover.backgroundColor
        headerView.addSubview(backgroudView); headerView.sendSubviewToBack(backgroudView)
        
        // Create swipe gesture to display delete button
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.deleteApear(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.deleteDisapear(_:)))
        leftSwipe.direction = .left; rightSwipe.direction = .right
        headerView.addGestureRecognizer(leftSwipe); headerView.addGestureRecognizer(rightSwipe)
        
        // Makeing delete button have tap functionality since it's not a real button but just a view
        headerView.deleteButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        headerView.deleteButton.setTitle(String(section), for: .normal); headerView.deleteButton.setTitleColor(UIColor.red, for: .normal) // My way of sending section info to delete action, otherwise wouldn't know which team to delete
        headerView.tag = section+1 // Lets swipe action know what section to make delete button to appear
        
        
        // Setting up Header view
        let team = favTeams[section]
        let name = team.value(forKeyPath:"name") as! String
        let abbreviation = team.value(forKeyPath:"abbreviation") as! String
        let color = team.value(forKeyPath:"color") as! Array<Int>
        
        retreiveImage(abbreviation: abbreviation.lowercased(), imageView: headerView.image)
        headerView.title.text = name
        headerView.border.backgroundColor = UIColor(red: color[0], green: color[1], blue: color[2])
                
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
    
    // Setting up display for last and next game
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FavoritesTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FavoritesTableViewCell else {fatalError("The dequed cell is not an instance of FavoritesTableViewCell.")}
        
        let team = favTeams[indexPath.section]
        let name = team.value(forKeyPath:"name") as! String

        if indexPath.row == 0 {
            cell.nextGame.text = "Last Game"
            if let game = favTeamGames[name]!["yest"] {
                cell.timeLabel.isHidden = true
                cell.team1Name.text = game.home
                cell.team1Logo.downloadImage(from: game.homeLogo)
                cell.team2Name.text = game.away
                cell.team2Logo.downloadImage(from: game.awayLogo)
                cell.team1Score.text = String(game.home_score!)
                cell.team2Score.text = String(game.away_score!)
            }
        } else {
            cell.nextGame.text = "Next Game"
            if let game = favTeamGames[name]!["today"] {
                cell.team1Score.isHidden = true; cell.team2Score.isHidden = true
                cell.team1Name.text = game.home
                cell.team1Logo.downloadImage(from: game.homeLogo)
                cell.team2Name.text = game.away
                cell.team2Logo.downloadImage(from: game.awayLogo)
                cell.timeLabel.text = game.time
            }
        }
        
        return cell
    }

    // Grabbing team logo images
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
       URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func retreiveImage(abbreviation: String, imageView: UIImageView?) {
        let url = URL(string: "https://www.nba.com/.element/img/1.0/teamsites/logos/teamlogos_500x500/"+abbreviation+".png")!
        getData(from: url) {
           data, response, error in
           guard let data = data, error == nil else {
              return
           }
           DispatchQueue.main.async() {
            imageView?.image = UIImage(data: data)!
           }
        }

    }
    
    // Retreiving core data
    func getCore() {
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

    
}

// Just making it easier to create custom color for each team logo background, want it to be slightly transparent and don't wanna write Int/255 for red blue and green for each new entry
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 0.5)
    }
}





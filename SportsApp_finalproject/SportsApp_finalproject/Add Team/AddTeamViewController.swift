//
//  AddTeamViewController.swift
//  SportsApp_finalproject
//
//  Created by Doherty, Benjamin J on 11/11/19.
//  Copyright © 2019 Doan, Douglas T. All rights reserved.
//

import UIKit
import CoreData
import os.log

class AddTeamViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, sportsDataProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var TeamName: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    var sports = SportsData()
    private var searchString: String = "" // Team we're searching for
    var teamList = Set<Array<String>>()                //List of all teams
    private var teamsSearched = Array<Array<String>>() //List of teams with our search in the name
    var teamSelected: [String]? = nil   // The team clicked on
    var saving = 0 //Dictates whether searching or saving data
    var saveData = Array<Array<String>>() // Data we're saving
    var favTeam: NSManagedObject? // Team sending to favs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TeamName.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        self.sports.delegate = self
        
        updateSaveButtonState(); updateSearchButtonState()
    }
    
    // MARK: Actions

    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func search(_ sender: UIButton) {     // Searching for teams
        teamsSearched.removeAll() // Resets results when searching again
        teamSelected = nil; saving = 0 // Cancels out any selected teams
        searchString = TeamName.text!
        
        if teamList == [] {     // If we don't have a list of teams we access the api to make one
            print("Looking at api")
            self.sports.getData()   // Accesses api and fills teamList
        }
        else {
            print("Using teamList")
            for team in teamList {      // If team name contains substring of our search the add it to our teamsSearched
                if team[0].lowercased().contains(searchString.lowercased()){
                    teamsSearched.append(team)
                }
            }
            DispatchQueue.main.async() {
                self.errorLabel.isHidden = false
                self.tableView.reloadData() // Displays data on table
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // Saving and sending back to Favorites View
        
        super.prepare(for: segue, sender: sender)
        save()
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
    }
    
    func save() { // Access core data and save team
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
          
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Team", in: managedContext)!
        let team = NSManagedObject(entity: entity,insertInto: managedContext)
        
        let rgb = retreiveColor(abbreviation: teamSelected![1])
          
        team.setValue(teamSelected![0], forKey: "name")
        team.setValue(teamSelected![1], forKey: "abbreviation")
        team.setValue(rgb, forKey: "color")
        team.setValue(saveData, forKey: "game")
        
        do {
            try managedContext.save()
        } catch {
            let nserror = error as NSError
            NSLog("Unable to save \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        favTeam = team
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       // User finished typing (hit return): hide the keyboard.
       textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) { // Updates save after editing
        updateSearchButtonState()
        updateSaveButtonState()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) { // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    private func updateSaveButtonState() { // Disable the Save Button unless team selected
        var select: Bool
        if teamSelected == nil {
            select = false
        } else { select = true }
        saveButton.isEnabled = select
    }
    private func updateSearchButtonState() {
        let text = TeamName.text ?? ""
        searchButton.isEnabled = !text.isEmpty
    }
    
    
    // MARK: Table View    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamsSearched.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TeamTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TeamTableViewCell else {fatalError("The dequed cell is not an instance of TeamTableViewCell.")}


        errorLabel.isHidden = true
        let url = URL(string: "https://www.nba.com/.element/img/1.0/teamsites/logos/teamlogos_500x500/"+teamsSearched[indexPath.row][1].lowercased()+".png")!
        cell.teamNameLabel.text = teamsSearched[indexPath.row][0]
        cell.teamLogo.downloadImage(from: url)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If view is tapped save that team info, and get data on their games
        teamSelected = teamsSearched[indexPath.row]
        saving = 1
        self.sports.getData()
        updateSaveButtonState()
        print("\(teamSelected!) are selected")
    }
    
    
    // MARK: Data Protocol
    
    func responseDataHandler(data: NSDictionary) {
        let games = data["games"] as! NSArray
        var counter = 0
        
        switch saving {
        case 1:     // When saving
            
            while counter < games.count { // Look through all games, if team is playing then save that data
                let CurrentMatch = games[counter] as! NSDictionary
                let away = CurrentMatch["away"] as! NSDictionary; let home = CurrentMatch["home"] as! NSDictionary
                let awayName = away["name"] as! String; let homeName = home["name"] as! String
                
                if awayName.lowercased() == teamSelected![0].lowercased() || homeName.lowercased() == teamSelected![0].lowercased() {
                    saveData.append([CurrentMatch["id"]! as! String,CurrentMatch["scheduled"]! as! String])
                }
                    
                counter += 1
            }
        
        default:    // If searching for data
            
            //Look at the schedule for the whole year and made a set of all the teams so we can search though 30 teams rather than the 1230 games in the season schedule everytime.
            while counter < games.count {
                let CurrentMatch = games[counter] as! NSDictionary
                let away = CurrentMatch["away"] as! NSDictionary
                let home = CurrentMatch["home"] as! NSDictionary
                
                teamList.insert([away["name"] as! String,away["alias"] as! String])
                teamList.insert([home["name"] as! String,home["alias"] as! String])
                
                counter += 1
            }
            
            // If team name contains substring of our search the add it to our teamsSearched
            for team in teamList {
                if team[0].lowercased().contains(searchString.lowercased()){
                    teamsSearched.append(team)
                }
            }
            DispatchQueue.main.async() {
                self.errorLabel.isHidden = false
                self.tableView.reloadData() // Displays data on table
            }
        }
    }
       
    func responseError(message: String) {
        print(message)
    }
    
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
    
    // List of every teams color, couldn't find api but found list online so just made set of all the data
    func retreiveColor(abbreviation: String) -> Array<Int> {
        let test: [String: [Int]] = ["ATL": [200, 16, 46], "BKN": [1, 1, 1], "BOS": [0, 122, 51], "CHA": [32, 23, 71], "CHI": [186, 12, 47], "CLE": [111, 38, 61], "DAL": [0, 80, 181], "DEN": [65, 143, 222], "DET": [0, 61, 165], "GSW": [255, 199, 44], "HOU": [186, 12, 47], "IND": [4, 30, 66], "LAC": [213, 0, 50], "LAL": [112, 47, 138], "MEM": [35, 55, 91], "MIA": [134, 38, 51], "MIL": [44, 82, 52], "MIN": [0, 42, 92], "NOP": [0, 43, 92], "NYK": [0, 61, 165], "OKC": [0, 125, 195], "ORL": [0, 125, 197], "PHI": [0, 102, 182], "PHX": [229, 96, 32], "POR": [240, 22, 58], "SAC": [114, 76, 159], "SAS": [182, 191, 191], "TOR": [206, 17, 65], "UTA": [0, 43, 92], "WAS": [12, 35, 64]]
        return test[abbreviation.uppercased()]!
    }
    
}

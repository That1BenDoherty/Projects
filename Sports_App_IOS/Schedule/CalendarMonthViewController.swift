//
//  CalendarMonthViewController.swift
//  SportsApp_finalproject
//
//  Created by Doherty, Benjamin J on 11/17/19.
//  Copyright © 2019 Doan, Douglas T. All rights reserved.
//

import UIKit
import os.log

class CalendarMonthViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var calendar: UICollectionView!
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    var selectedIndex: IndexPath? = nil // Index of dat tapped on
    var selectedDate = Date()
    var thisDate: Date?
    // Range of days in 2019 - 2020 Nba schedule, rather than loading an api each time clicked
    let gameRange = [Date(timeIntervalSinceReferenceDate: 593395200), Date(timeIntervalSinceReferenceDate: 608601600)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.calendar.scrollToItem(at: [Date().monthsAway(gameRange[0]),30], at: .top, animated: true)
    }
          
    func scrollToIndex() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
            if self.selectedIndex != nil {
                self.calendar.scrollToItem(at: self.selectedIndex!, at: .centeredVertically, animated: true)
            }
        }
    }
    

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 7
    }
    
    // Sets header to be month and year
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
        let title = headerView.viewWithTag(1) as! UILabel
        title.text = gameRange[0].addMonthFC(month: indexPath.section).getHeaderTitleFC()
        
        return headerView
    }
    
    // Sets rows to day in each month (plus end dates from previous and next month)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let days = gameRange[0].addMonthFC(month: section).getDaysInMonthFC()+gameRange[0].addMonthFC(month: section).startOfMonthFC().getDayOfWeekFC()!+6
        return (days + 7-(days % 7))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let calendarDay = cell.viewWithTag(1) as! UILabel
        calendarDay.textColor = UIColor.darkGray
        
        var dateComponents = DateComponents()
        dateComponents.year = Int(gameRange[0].addMonthFC(month: indexPath.section).getYearOnlyFC())!
        dateComponents.month = Int(gameRange[0].addMonthFC(month: indexPath.section).getMonthOnlyFC())!
        dateComponents.day = 1000
        dateComponents.timeZone = TimeZone(abbreviation: "CST")
        dateComponents.hour = -6
        dateComponents.minute = 0
        
        // If date is not just the days of week
        if indexPath.row+1 >= gameRange[0].addMonthFC(month: indexPath.section).startOfMonthFC().getDayOfWeekFC()!+7{
            let daysInMonth = gameRange[0].addMonthFC(month: indexPath.section).getDaysInMonthFC()+gameRange[0].addMonthFC(month: indexPath.section).startOfMonthFC().getDayOfWeekFC()!+6
            if indexPath.row >= daysInMonth { // For last couple days in the row that are part of next month
                calendarDay.text = "\(indexPath.row - daysInMonth + 1)" ; dateComponents.day = indexPath.row - daysInMonth + 1; dateComponents.month = dateComponents.month! + 1
                calendarDay.textColor = UIColor(red: 200/225, green: 0, blue: 0, alpha: 0.3)
            } else { // Sets text for days of month
                let daysOfMonth = (indexPath.row+1)-(gameRange[0].addMonthFC(month: indexPath.section).startOfMonthFC().getDayOfWeekFC()!+6)
                calendarDay.text = "\(daysOfMonth)"; dateComponents.day = daysOfMonth
            }
        }else{ // Sets lebel for days of week
            if(indexPath.row < 7){
                var dayname = ""
                print(indexPath)
                switch (indexPath.row){
                case 0:
                    dayname = "S"
                    break
                    
                case 1:
                    dayname = "M"
                    break
                    
                case 2:
                    dayname = "T"
                    break
                    
                case 3:
                    dayname = "W"
                    break
                    
                case 4:
                    dayname = "T"
                    break
                    
                case 5:
                    dayname = "F"
                    break
                    
                case 6:
                    dayname = "S"
                    break
                    
                default:
                    break
                }
                calendarDay.text = dayname
                calendarDay.textColor = UIColor.lightGray
            }else{ // Days in first row, from previous month
                let daysOfLastMonth = Int(gameRange[0].addMonthFC(month: indexPath.section-1).endOfMonthFC().getDayFC())! + (indexPath.row+1) - 6 - gameRange[0].addMonthFC(month: indexPath.section).startOfMonthFC().getDayOfWeekFC()!
                calendarDay.text = "\(daysOfLastMonth)"; dateComponents.day = daysOfLastMonth; dateComponents.month = dateComponents.month! - 1
                calendarDay.textColor = UIColor(red: 200/225, green: 0, blue: 0, alpha: 0.3)
            }
        }
        cell.viewWithTag(2)?.isHidden = true // Hiding blue circle except on day selected
        cell.viewWithTag(2)?.layer.cornerRadius = (cell.viewWithTag(2)?.frame.width)!/2
        if(selectedIndex != nil){ // Setting up blue circle for today, happens only when loading view
            if(selectedIndex == indexPath){
                cell.viewWithTag(2)?.isHidden = false
                calendarDay.textColor = UIColor.white
                self.scrollToIndex()
            }
        }else if Int(calendarDay.text!) != nil{ // Moving blue circle to selected day
            if(gameRange[0].addMonthFC(month: indexPath.section).startOfMonthFC().getDayFC(day: Int(calendarDay.text!)!-1) == selectedDate.getDayFC(day: 0)){
                cell.viewWithTag(2)?.isHidden = false
                calendarDay.textColor = UIColor.white
                selectedDate = Date()
                selectedIndex = indexPath
            }
        }
        cell.viewWithTag(4)?.isHidden = true // Hidding dots except for days within league schedule
        //cell.viewWithTag(4)?.isUserInteractionEnabled = false
    
        if dateComponents.day != 1000 { // If day has day components (aka for all cells except weekday labels)
            let someDateTime = Calendar.current.date(from: dateComponents)
            if (someDateTime! > self.gameRange[0] || someDateTime! == self.gameRange[0]) && (someDateTime! < self.gameRange[1] || someDateTime! == self.gameRange[1]) { // If day is within league schedule display dot and make selectable
                cell.viewWithTag(4)?.isHidden = false
                //cell.viewWithTag(4)?.isUserInteractionEnabled = true
                }
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // If cell is selected,change blue dot, and send date to schedule view
        let cell = collectionView.cellForItem(at: indexPath)
        let calendarDay = cell?.viewWithTag(1) as! UILabel
        if Int(calendarDay.text!) != nil{
            cell?.viewWithTag(2)?.isHidden = false
            calendarDay.textColor = UIColor.white
            let sDate =  gameRange[0].addMonthFC(month: indexPath.section).startOfMonthFC().getDayFC(day: Int(calendarDay.text!)!-1)
            print(sDate)
            selectedDate = sDate
            selectedIndex = indexPath
            collectionView.reloadData()
            print(indexPath)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // Sending data to schedule view
        super.prepare(for: segue, sender: sender)
        
        DispatchQueue.main.async() { // Wait for selected date to load
            self.thisDate = self.selectedDate
        }
    }
    
    // Takes json's funcky date structure and puts it into hours and mins
    func jsonConvert(str: String) -> NSDate? {
        let str = String(str.dropLast(14))
        
        let dateFor: DateFormatter = DateFormatter()
        dateFor.dateFormat = "yyyy-MM-dd'T'"

        let yourDate: NSDate? = dateFor.date(from: str) as NSDate?
        
        return Calendar.current.date(byAdding: Calendar.Component.hour, value: -29, to: yourDate! as Date)! as NSDate
    }
    
}

private let itemsPerRow: CGFloat = 7
private let sectionInsets = UIEdgeInsets(top: 10.0,
left: 0.0,
bottom: 10.0,
right: 0.0)

extension CalendarMonthViewController : UICollectionViewDelegateFlowLayout { // Sets layout so displa shows right on any device

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    //2
    let paddingSpace = 13 * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow

    return CGSize(width: widthPerItem, height: widthPerItem)
    
  }
  

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.top
  }
}
    




extension Date { // Extention of date with some functions to quickly return data like days in month and such
    
    func getDaysInMonthFC() -> Int{
        let calendar = Calendar.current
        
        let dateComponents = DateComponents(year: calendar.component(.year, from: self), month: calendar.component(.month, from: self))
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        
        return numDays
    }
    
    func addMonthFC(month: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: month, to: self)!
    }
    
    func startOfMonthFC() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonthFC() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonthFC())!
    }
    
    func getDayOfWeekFC() -> Int? {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: self)
        return weekDay
    }
    
    func getDayFC() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
    
    func getCompFC() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMdd"
        return dateFormatter.string(from: self)
    }
    
    func getJsonFC() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    func getDayFC(day: Int) -> Date {
        let day = Calendar.current.date(byAdding: .day, value: day, to: self)!
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: day)!
    }
    
    func getYearOnlyFC() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        return dateFormatter.string(from: self)
    }
    
    func getMonthOnlyFC() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M"
        return dateFormatter.string(from: self)
    }
    
    func getTitleDateFC() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }
    
    func getHeaderTitleFC() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM, YYYY"
        return dateFormatter.string(from: self)
    }
    
    func monthsAway(_ date: Date) -> Int{
        if self.getYearOnlyFC() == date.getYearOnlyFC(){
            let distance = Int(self.getMonthOnlyFC())! - Int(date.getMonthOnlyFC())!
            if distance == 0{ return 0 } else { return distance - 1}
        }else{
            return 2 + Int(self.getMonthOnlyFC())!
        }
    }
}

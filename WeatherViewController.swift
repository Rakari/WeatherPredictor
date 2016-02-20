//
//  WeatherViewController.swift
//  WeatherPredictor
//
//  Created by BolloMini on 02/12/15.
//  Copyright © 2015 Bollagardar Productions. All rights reserved.
//

import UIKit
import Parse

extension NSDate
{
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
        {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func addDays(daysToAdd : Int) -> NSDate
    {
        let secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd : Int) -> NSDate
    {
        let secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}

class WeatherViewController: UITableViewController {
    var predictions : [PFObject] = []
    var temps : [String : Int] = [:]
    
    func averageTemp(objects:[PFObject]) -> PFObject {
        let avTemp : PFObject = PFObject()
        for object in objects {
            avTemp["current"] = (avTemp["current"] as! Int) + (object["current"] as! Int)
            
            avTemp["prediction1"] = (avTemp["prediction1"] as! Int) + (object["prediction1"] as! Int)
            avTemp["prediction2"] = (avTemp["prediction2"] as! Int) + (object["prediction2"] as! Int)
            avTemp["prediction3"] = (avTemp["prediction3"] as! Int) + (object["prediction3"] as! Int)
            avTemp["prediction4"] = (avTemp["prediction4"] as! Int) + (object["prediction4"] as! Int)
            avTemp["prediction5"] = (avTemp["prediction5"] as! Int) + (object["prediction5"] as! Int)
            avTemp["prediction6"] = (avTemp["prediction6"] as! Int) + (object["prediction6"] as! Int)
            avTemp["prediction7"] = (avTemp["prediction7"] as! Int) + (object["prediction7"] as! Int)
        }
        
        avTemp["current"] = (avTemp["current"] as! Int) / objects.count
        
        avTemp["prediction1"] = (avTemp["prediction1"] as! Int) / objects.count
        avTemp["prediction2"] = (avTemp["prediction2"] as! Int) / objects.count
        avTemp["prediction3"] = (avTemp["prediction3"] as! Int) / objects.count
        avTemp["prediction4"] = (avTemp["prediction4"] as! Int) / objects.count
        avTemp["prediction5"] = (avTemp["prediction5"] as! Int) / objects.count
        avTemp["prediction6"] = (avTemp["prediction6"] as! Int) / objects.count
        avTemp["prediction7"] = (avTemp["prediction7"] as! Int) / objects.count
        
        return avTemp
    }
    
    func fetchParseData() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let today = dateFormatter.dateFromString("02.12.2015 00:00")
        
        let calendar = NSCalendar.currentCalendar()
        var components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: calendar.dateByAddingUnit(.Day, value: -6, toDate: today!, options: NSCalendarOptions(rawValue:0))!)
        components.hour = 0
        components.minute = 0
        let searchStart = calendar.dateFromComponents(components)!
        
        components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: calendar.dateByAddingUnit(.Day, value: 6, toDate: today!, options: NSCalendarOptions(rawValue:0))!)
        components.hour = 23
        components.minute = 59
        let searchStop = calendar.dateFromComponents(components)!
        
        let query = PFQuery(className:"Data")
        query.whereKey("date", greaterThan: searchStart)
        query.whereKey("date", lessThan: searchStop)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                var currentDate = searchStart
                var rawTemps : [String : [Int]] = [:]
                
                dateFormatter.dateFormat = "dd.MM.yyyy"
                
                for object in objects! {
                    if object["date"].isEqualToDate(today!) {
                        // Todays date
                        rawTemps[dateFormatter.stringFromDate(currentDate)]! += [object["current"] as! Int]
                        
                        // Future dates
                        
                        // Adding one day to currentDate
                        components = calendar.components([.Year, .Month, .Day], fromDate: calendar.dateByAddingUnit(.Day, value: 1, toDate: currentDate, options: NSCalendarOptions(rawValue:0))!)
                        // Setting value for prediction for day 1
                        rawTemps[dateFormatter.stringFromDate(calendar.dateFromComponents(components)!)]! += [object["prediction1"] as! Int]
                        
                        // Adding two days to currentDate
                        components = calendar.components([.Year, .Month, .Day], fromDate: calendar.dateByAddingUnit(.Day, value: 2, toDate: currentDate, options: NSCalendarOptions(rawValue:0))!)
                        // Setting value for prediction for day 2
                        rawTemps[dateFormatter.stringFromDate(calendar.dateFromComponents(components)!)]! += [object["prediction2"] as! Int]
                        
                        // Adding three days to currentDate
                        components = calendar.components([.Year, .Month, .Day], fromDate: calendar.dateByAddingUnit(.Day, value: 3, toDate: currentDate, options: NSCalendarOptions(rawValue:0))!)
                        // Setting value for prediction for day 3
                        rawTemps[dateFormatter.stringFromDate(calendar.dateFromComponents(components)!)]! += [object["prediction3"] as! Int]
                        
                        // Adding four days to currentDate
                        components = calendar.components([.Year, .Month, .Day], fromDate: calendar.dateByAddingUnit(.Day, value: 4, toDate: currentDate, options: NSCalendarOptions(rawValue:0))!)
                        // Setting value for prediction for day 4
                        rawTemps[dateFormatter.stringFromDate(calendar.dateFromComponents(components)!)]! += [object["prediction4"] as! Int]
                        
                        // Adding five days to currentDate
                        components = calendar.components([.Year, .Month, .Day], fromDate: calendar.dateByAddingUnit(.Day, value: 5, toDate: currentDate, options: NSCalendarOptions(rawValue:0))!)
                        // Setting value for prediction for day 5
                        rawTemps[dateFormatter.stringFromDate(calendar.dateFromComponents(components)!)]! += [object["prediction5"] as! Int]
                        
                        // Adding six days to currentDate
                        components = calendar.components([.Year, .Month, .Day], fromDate: calendar.dateByAddingUnit(.Day, value: 6, toDate: currentDate, options: NSCalendarOptions(rawValue:0))!)
                        // Setting value for prediction for day 6
                        rawTemps[dateFormatter.stringFromDate(calendar.dateFromComponents(components)!)]! += [object["prediction6"] as! Int]
                    }
                    else if object["date"].isEqualToDate(currentDate) {
                        // Todays date
                        rawTemps[dateFormatter.stringFromDate(currentDate)]! += [object["current"] as! Int]
                    } else {
                        components = calendar.components([.Year, .Month, .Day], fromDate: calendar.dateByAddingUnit(.Day, value: 1, toDate: currentDate, options: NSCalendarOptions(rawValue:0))!)
                        currentDate = calendar.dateFromComponents(components)!
                    }
                }
        
                //let avTemp = totalTemp/objects!.count
                self.predictions += [objects![0], objects![4], objects![8], objects![12], objects![16], objects![20], objects![24], objects![28], objects![32], objects![36], objects![40], objects![44], objects![48]]
                self.tableView.reloadData()
            } else {
                print(error)
            }
            
            let indexPath = NSIndexPath(forRow: 12, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchParseData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 13
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height : CGFloat = 0.0
        
        if indexPath.row == 6 { // Today
            height = 102.0
        } else { // Other days
            height = 67.0
        }
        
        return height
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var returnCell : UITableViewCell = UITableViewCell()
        
        if predictions.count > 0 {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            dateFormatter.locale = NSLocale(localeIdentifier: "is_IS")
            let today = dateFormatter.dateFromString("02.12.2015")
            
            var predDate = predictions[indexPath.row]["date"] as! NSDate
            let predTemp = predictions[indexPath.row]["current"] as! Int
            
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: calendar.dateByAddingUnit(.Day, value: 0, toDate: predDate, options: NSCalendarOptions(rawValue:0))!)
            components.hour = 0
            components.minute = 0
            
            predDate = calendar.dateFromComponents(components)!
            let date = dateFormatter.stringFromDate(predDate)
        
            dateFormatter.dateFormat = "EEEE"
            let weekDay = dateFormatter.stringFromDate(predDate)
            
            print(weekDay)
            
            if predDate.isEqualToDate(today!) { //This will be changed to NSDate.date() in the future
                let cell = tableView.dequeueReusableCellWithIdentifier("TodayCell", forIndexPath: indexPath) as! TodayCell
            
                if predTemp > 0 {
                    cell.tempLabel.textColor = UIColor(red: 255/255, green: 61/255, blue: 66/255, alpha: 1.0)
                } else {
                    cell.tempLabel.textColor = UIColor(red: 74/255, green: 99/255, blue: 255/255, alpha: 1.0)
                }
                
                //cell.tempLabel.font = UIFont.systemFontOfSize(48)
                
                cell.tempLabel.text = "\(predTemp)˚C"
                cell.dateLabel.text = "í dag \n\(date)"
            
                returnCell = cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("OtherDayCell", forIndexPath: indexPath) as! OtherDayCell
                
                if predTemp > 0 {
                    cell.tempLabel.textColor = UIColor(red: 255/255, green: 61/255, blue: 66/255, alpha: 1.0)
                } else {
                    cell.tempLabel.textColor = UIColor(red: 74/255, green: 99/255, blue: 255/255, alpha: 1.0)
                }
                
                cell.tempLabel.text = "\(predTemp)˚C"
                cell.dateLabel.text = "\(weekDay) \n\(date)"
                
                returnCell = cell

            }
        }
        
        /*if temps.count > 0 {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            dateFormatter.locale = NSLocale(localeIdentifier: "is_IS")
            let today = dateFormatter.dateFromString("02.12.2015")
            
            let predDate = dateFormatter.dateFromString(Array(temps.keys)[indexPath.row])
            let predTemp = temps[Array(temps.keys)[indexPath.row]]  
            
            dateFormatter.dateFormat = "EEEE"
            let weekDay = dateFormatter.stringFromDate(predDate)
            
            print(weekDay)
            
            if predDate.isEqualToDate(today!) { //This will be changed to NSDate.date() in the future
                let cell = tableView.dequeueReusableCellWithIdentifier("TodayCell", forIndexPath: indexPath) as! TodayCell
                
                if predTemp > 0 {
                    cell.tempLabel.textColor = UIColor(red: 255/255, green: 61/255, blue: 66/255, alpha: 1.0)
                } else {
                    cell.tempLabel.textColor = UIColor(red: 74/255, green: 99/255, blue: 255/255, alpha: 1.0)
                }
                
                //cell.tempLabel.font = UIFont.systemFontOfSize(48)
                
                cell.tempLabel.text = "\(predTemp)˚C"
                cell.dateLabel.text = "í dag \n\(date)"
                
                returnCell = cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("OtherDayCell", forIndexPath: indexPath) as! OtherDayCell
                
                if predTemp > 0 {
                    cell.tempLabel.textColor = UIColor(red: 255/255, green: 61/255, blue: 66/255, alpha: 1.0)
                } else {
                    cell.tempLabel.textColor = UIColor(red: 74/255, green: 99/255, blue: 255/255, alpha: 1.0)
                }
                
                cell.tempLabel.text = "\(predTemp)˚C"
                cell.dateLabel.text = "\(weekDay) \n\(date)"
                
                returnCell = cell
                
            }

        }*/
        
        return returnCell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}


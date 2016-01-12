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
    
    
    /*func isEqualDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame
        {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }*/
    
    
    
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
                var totalTemp = 0
                for object in objects! {
                    totalTemp += object["current"] as! Int
                    print(object)
                }
                //let avTemp = totalTemp/objects!.count
                
            } else {
                print(error)
            }
            self.tableView.reloadData()
            
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
        return 1
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
            let predDate = predictions[indexPath.row]["date"] as! NSDate
            let predTemp = predictions[indexPath.row]["current"] as! Int
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            dateFormatter.locale = NSLocale(localeIdentifier: "is_IS")
            let today = dateFormatter.dateFromString("02.12.2015")
            
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
                
                cell.tempLabel.text = "\(predTemp)˚C"
                cell.dateLabel.text = "\(weekDay) /n \(date)"
            
                returnCell = cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("OtherDayCell", forIndexPath: indexPath) as! OtherDayCell
                
                if predTemp > 0 {
                    cell.tempLabel.textColor = UIColor(red: 255/255, green: 61/255, blue: 66/255, alpha: 1.0)
                } else {
                    cell.tempLabel.textColor = UIColor(red: 74/255, green: 99/255, blue: 255/255, alpha: 1.0)
                }
                
                cell.tempLabel.text = "\(predTemp)˚C"
                cell.dateLabel.text = "\(weekDay) /n \(date)"
                
                returnCell = cell

            }
        }
        
        return returnCell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

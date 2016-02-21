//
//  WeatherViewController.swift
//  WeatherPredictor
//
//  Created by BolloMini on 02/12/15.
//  Copyright © 2015 Bollagardar Productions. All rights reserved.
//

import UIKit

class WeatherViewController: UITableViewController {
    var mWeatherData     : WeatherData!
    var mFocusDate       : NSDate!
    var mTemperatures    : [Temperature] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        mFocusDate = dateFormatter.dateFromString("02.12.2015 00:00")!

        mWeatherData = WeatherData()
        
        mWeatherData.fetchParseData(mFocusDate,tableView: self.tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mTemperatures = mWeatherData.getAverageTemperatures(mFocusDate)
        
        return mTemperatures.count
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
        
        if mTemperatures.count > 0 {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            dateFormatter.locale = NSLocale(localeIdentifier: "is_IS")
            let today = dateFormatter.dateFromString("02.12.2015")
            
            var predDate = mTemperatures[indexPath.row].date
            let predTemp = mTemperatures[indexPath.row].value
            
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: calendar.dateByAddingUnit(.Day, value: 0, toDate: predDate, options: NSCalendarOptions(rawValue:0))!)
            components.hour = 0
            components.minute = 0
            
            predDate = calendar.dateFromComponents(components)!
            let date = dateFormatter.stringFromDate(predDate)
        
            dateFormatter.dateFormat = "EEEE"
            let weekDay = dateFormatter.stringFromDate(predDate)
            
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


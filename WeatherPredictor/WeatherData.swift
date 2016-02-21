//
//  WeatherData.swift
//  WeatherPredictor
//
//  Created by Rögnvaldur Sæmundsson on 10.2.2016.
//  Copyright © 2016 Bollagardar Productions. All rights reserved.
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
    
    func isEqualDate(dateToCompare : NSDate) -> Bool
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
    
    func isEqualDay(dateToCompare : NSDate) -> Bool{
        return NSCalendar.currentCalendar().isDate(self, equalToDate: dateToCompare, toUnitGranularity: .Day)
    }

}

class Temperature {
    var date : NSDate
    var value : Double
    init(){
        value = 0
        date = NSDate()
    }
    init(aDate : NSDate, aValue : Double){
        value = aValue
        date = aDate
    }
}

class WeatherData: NSObject {
    var mParseData : [PFObject] = []
    var mStartDate : NSDate
    var mStopDate : NSDate
    var mTableView : UITableView!
    var mNumDaysBackAndForward : Int
    
    override init() {
        mStartDate = NSDate()
        mStopDate = NSDate()
        mNumDaysBackAndForward = 6
    }
    
    func fetchParseData(focusDate : NSDate, tableView : UITableView) {
        //  Fetch records centered around the focus date. Historical records backward and predictions forward
        //  Predictions are all found in the records of the focusdate.
        
        mTableView = tableView
        
        
        // Create the start and stop dates for the query
        
        let calendar = NSCalendar.currentCalendar()
        var components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: calendar.dateByAddingUnit(.Day, value: -mNumDaysBackAndForward, toDate: focusDate, options: NSCalendarOptions(rawValue:0))!)
        components.hour = 0
        components.minute = 0
        self.mStartDate = calendar.dateFromComponents(components)!
        
        components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: calendar.dateByAddingUnit(.Day, value: 1, toDate: focusDate, options: NSCalendarOptions(rawValue:0))!)
        components.hour = 0
        components.minute = 0
        self.mStopDate = calendar.dateFromComponents(components)!
        
        // Build the query
        
        let query = PFQuery(className:"Data")
        query.whereKey("date", greaterThan: mStartDate)
        query.whereKey("date", lessThan: mStopDate)
        query.orderByAscending("date")
        
        mStopDate = focusDate   // Reset mStopDate to focusDate because we had added one day to much
        
        // Run the query and calculate the average for each day
        // Each timestamp should hold current value and seven days forward prediction.
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                self.mParseData = objects!
                self.mTableView.reloadData()
                print("Gögnin komin")
            } else {
                print(error)
            }
        }
        
    }
    
    func getAverageTemperatures(focusDate : NSDate) -> [Temperature] {
        
        // Fetch data from server if not already there
        if (focusDate.isEqualDay(self.mStopDate) == false) {
            fetchParseData(focusDate,tableView: mTableView)
        }
        
        var currentDate = mStartDate
        var temperatures : [Temperature] = []
        var countMeasurements = 0
        var predictions : [Temperature] = []
        
        temperatures.append(Temperature())   // Add the first value to the array to return
        
        for _ in 0...mNumDaysBackAndForward {
            predictions.append(Temperature())
        }
        
        print("Lengd mParseData: \(mParseData.count)")
        
        for object in mParseData {
            print("Núverandi dagsetning: \(object["date"] as! NSDate)")
            print("Núverandi hitastig: \(object["current"] as! Int)")
            if (object["date"] as! NSDate).isEqualDay(currentDate){
                //  If measurements are from the same date they are averaged
                //  First added together and then divided by the count once all are found
                //  The focusdate is special because it has the predictions for six days ahead
               
                temperatures[temperatures.count-1].value += object["current"] as! Double
                countMeasurements++
                
                // NOTE: number of predictions is hardcoded here
                if (object["date"] as! NSDate).isEqualDay(focusDate){
                    predictions[0].value += object["prediction1"] as! Double
                    predictions[1].value += object["prediction2"] as! Double
                    predictions[2].value += object["prediction3"] as! Double
                    predictions[3].value += object["prediction4"] as! Double
                    predictions[4].value += object["prediction5"] as! Double
                    predictions[5].value += object["prediction6"] as! Double
                }
            } else {
                // All measurements have been found and we divide by the count to find average
                // and add the date
                temperatures[temperatures.count-1].value /= Double(countMeasurements)
                temperatures[temperatures.count-1].date = currentDate
                print("Meðaltal \(currentDate) : \(temperatures[temperatures.count-1].value)")
                countMeasurements = 0
                
                // Reset currentDate with the new date and add the first value
                currentDate = object["date"] as! NSDate
                temperatures.append(Temperature())    // count will increase by one
                temperatures[temperatures.count-1].value += object["current"] as! Double
                countMeasurements++
            }
            
        }
        
        // Calculate the mean and set the date for the last date (which is focusDate) as well as the predictions
        temperatures[temperatures.count-1].value /= Double(countMeasurements)
        temperatures[temperatures.count-1].date = currentDate
        
        // NOTE: number of predictions is hardcoded here
        predictions[0].value /= Double(countMeasurements)
        predictions[0].date = currentDate.addDays(1)
        predictions[1].value /= Double(countMeasurements)
        predictions[1].date = predictions[0].date.addDays(1)
        predictions[2].value /= Double(countMeasurements)
        predictions[2].date = predictions[1].date.addDays(1)
        predictions[3].value /= Double(countMeasurements)
        predictions[3].date = predictions[2].date.addDays(1)
        predictions[4].value /= Double(countMeasurements)
        predictions[4].date = predictions[3].date.addDays(1)
        predictions[5].value /= Double(countMeasurements)
        predictions[5].date = predictions[4].date.addDays(1)
        
        // Append the predictions to the list
        temperatures.append(predictions[0])
        temperatures.append(predictions[1])
        temperatures.append(predictions[2])
        temperatures.append(predictions[3])
        temperatures.append(predictions[4])
        temperatures.append(predictions[5])
        
        return temperatures
    }
    
    func getDailyTemperatures(date : NSDate) -> [Temperature] {
        var temperatures : [Temperature] = []
        var found : Bool = false
        
        // Assumes date is in mParseData. If not nothing is returned.
        
        for object in mParseData {
            if (object["date"] as! NSDate).isEqualDay(date){
                temperatures.append(Temperature(aDate: object["date"] as! NSDate, aValue: object["current"] as! Double))
                found = true
            } else {
                if (found == true){
                    break   // Break if we have already found our date
                }
            }
        }
        return temperatures
    }

}

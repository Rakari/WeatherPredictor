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
    var parseData : [PFObject] = []
    var startDate : NSDate
    var stopDate : NSDate
    
    override init() {
        startDate = NSDate()
        stopDate = NSDate()
    }
    
    func fetchParseData(focusDate : NSDate) {
        //  Fetch records centered around the focus date. Historical records backward and predictions forward
        //  Predictions are all found in the records of the focusdate.
        
        let numDaysBack = 6
        
        // Create the start and stop dates for the query
        
        let calendar = NSCalendar.currentCalendar()
        var components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: calendar.dateByAddingUnit(.Day, value: -numDaysBack, toDate: focusDate, options: NSCalendarOptions(rawValue:0))!)
        components.hour = 0
        components.minute = 0
        self.startDate = calendar.dateFromComponents(components)!
        
        components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: calendar.dateByAddingUnit(.Day, value: 1, toDate: focusDate, options: NSCalendarOptions(rawValue:0))!)
        components.hour = 0
        components.minute = 0
        self.stopDate = calendar.dateFromComponents(components)!
        
        // Build the query
        
        let query = PFQuery(className:"Data")
        query.whereKey("date", greaterThan: startDate)
        query.whereKey("date", lessThan: stopDate)
        
        // Run the query and calculate the average for each day
        // Each timestamp should hold current value and seven days forward prediction.
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                self.parseData = objects!
            } else {
                print(error)
            }
        }
        
    }
    
    func getAverageTemperatures(focusDate : NSDate) -> [Temperature] {
        
        // Fetch data from server if not already there
        if (focusDate.isEqualDate(self.stopDate) == false) {
            fetchParseData(focusDate)
        }
        
        var currentDate = startDate
        var temperatures : [Temperature] = []
        var countMeasurements = 0
        
        temperatures[0].value = 0   // Add the first value to the array
        
        for object in parseData {
            if (object["date"] as! NSDate).isEqualDay(currentDate){
                // If measurements are from the same date they are averaged
                //  First added together and then divided by the count once all are found
                temperatures[temperatures.count-1].value += object["current"] as! Double
                countMeasurements++
            } else {
                // All measurements have been found and we divide by the count to find average
                // and add the date
                temperatures[temperatures.count-1].value /= Double(countMeasurements)
                temperatures[temperatures.count-1].date = currentDate
                
                // Reset counter and add next value to the array
                countMeasurements = 0
                
                // Reset currentDate with the new date and add the first value
                currentDate = object["date"] as! NSDate
                temperatures[temperatures.count].value = 0    // count will increase by one
                temperatures[temperatures.count-1].value += object["current"] as! Double
                countMeasurements++
            }
            
        }
        return temperatures
    }
    
    func getDailyTemperatures(date : NSDate) -> [Temperature] {
        var temperatures : [Temperature] = []
        var found : Bool = false
        
        for object in parseData {
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

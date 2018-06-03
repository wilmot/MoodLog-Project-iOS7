//
//  Utilities.swift
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 5/19/17.
//  Copyright © 2017 Barry A. Langdon-Lassagne. All rights reserved.
//

import UIKit

let kPieOrDonutChartKey = "pieOrDonutChartDefault"
public var pieOrDonutChart: Bool = false // false is pie, true is donut

@objc public class PieOrDonut: NSObject {
 
    override public init() {
    }
    
    @objc class func donut() -> Bool {
        let defaults = UserDefaults.standard

        // pie or donut
        if defaults.object(forKey: kPieOrDonutChartKey) == nil {
            defaults.set(pieOrDonutChart, forKey: kPieOrDonutChartKey)
            defaults.synchronize()
        }
        pieOrDonutChart = defaults.bool(forKey: kPieOrDonutChartKey)
        return pieOrDonutChart
    }
}

extension UIColor {
    class func color(withData data:Data) -> UIColor {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! UIColor
    }
    
    func encode() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
    
    func lighter(by percentage:CGFloat=30.0) -> UIColor {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }
        else{
            return self
        }
    }
}

extension CGRect {
    func center() -> CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}

var DEBUGGING: Bool {
    get {
        if let debug = Bundle.main.infoDictionary?["Debugging"] as? Bool {
            return debug
        }
        return false
    }
}

func prettyDateAndTime(_ date: NSDate?) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/YY hh:mm:ss a"
    let dateString: String
    if let date = date {
        dateString = dateFormatter.string(from: date as Date)
    }
    else {
        dateString = ""
    }
    return dateString
}

// Debug Print
func dprint(_ text: String) {
    if DEBUGGING {
        let date = NSDate()
        print("\(prettyDateAndTime(date)): \(text)")
    }
}

func message(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: NSLocalizedString("OK",  comment: "OK button"), style: .default, handler: {
        alert -> Void in
    })
    alertController.addAction(action)
    // Walk the hierarchy to find a place to display the alert
    var currentVC = UIApplication.shared.keyWindow?.rootViewController
    while ((currentVC?.presentedViewController) != nil) {
       currentVC = currentVC?.presentedViewController
    }
    currentVC?.present(alertController, animated: true, completion: nil)
}

func escapeHTMLStuff(string: String) -> String {
    var newString = string
    let char_dictionary = [
        "<" : "\\<",
        ">" : "\\>",
        "/" : "\\/",
        "\\" : "\\\\"
    ];
    for (unescaped_char, escaped_char) in char_dictionary {
        newString = newString.replacingOccurrences(of: unescaped_char, with: escaped_char, options: NSString.CompareOptions.literal, range: nil)
    }
    return newString
}

func htmlifyCharacters(string: String) -> String {
    var newString = string
    let char_dictionary = [
        "\n" : "<br>",
        "‘" : "&lsquo;",
        "’" : "&rsquo;" ,
        "“" : "&ldquo;",
        "”" : "&rdquo;"
    ];
    for (unescaped_char, escaped_char) in char_dictionary {
        newString = newString.replacingOccurrences(of: unescaped_char, with: escaped_char, options: NSString.CompareOptions.literal, range: nil)
    }
    return newString
}

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

/// The available states of being logged in or not.
enum AuthenticationState {
    case loggedin, loggedout
}

var xloggedInState: AuthenticationState = .loggedout
var privacyPIN = "1822"
var pinMax = 4

// Perform something after a delay
// e.g. delay(0.5) { dprint("hello") }
func delay(_ time: Double, aFunc: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + TimeInterval(time)) {
        aFunc()
    }
}

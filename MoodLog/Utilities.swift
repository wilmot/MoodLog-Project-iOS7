//
//  Utilities.swift
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 5/19/17.
//  Copyright © 2017 Barry A. Langdon-Lassagne. All rights reserved.
//

import UIKit

let kPieOrDonutChartKey = "pieOrDonutChartDefault"
let kPrivacyScreenKey = "privacyScreenKey"
let kPrivacyPINDefault = "privacyPINDefault"
let numberBalls = ["⓪","①","②","③","④","⑤","⑥","⑦","⑧","⑨"]
var loggedInState: AuthenticationState = .loggedout

public var pieOrDonutChart: Bool = false // false is pie, true is donut

@objc public class AppVersion: NSObject {
@objc class func moodLogVersion() -> String {
    if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
        let infoPlist = NSDictionary(contentsOfFile: path)
        if let infoPlist = infoPlist {
            let ver = infoPlist["CFBundleShortVersionString"] as? String ?? "1.1"
            let build = infoPlist["CFBundleVersion"] as? String ?? "--"
            return "\(ver) (\(build))"
        }
    }
    return ""
}
}

// Expose setting to ObjC
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

@objc public class PrivacyScreen: NSObject {
    
    override public init() {
    }
    
    @objc class func isOn() -> Bool {
        let defaults = UserDefaults.standard
        
        if let appDelegate = (UIApplication.shared.delegate as? MlAppDelegate) {
            if defaults.object(forKey: kPrivacyScreenKey) == nil {
                defaults.set(appDelegate.showPrivacyScreen, forKey: kPrivacyScreenKey)
                defaults.synchronize()
            }
            var hasPINObject = false
            if let _ = defaults.object(forKey: kPrivacyPINDefault) {
                hasPINObject = true
            }
            appDelegate.showPrivacyScreen = defaults.bool(forKey: kPrivacyScreenKey) && hasPINObject
            return appDelegate.showPrivacyScreen
        }
        return false
    }
}

@objc public class LoggedInState: NSObject {
    
    override public init() {
    }
    
    @objc class func loggedIn() -> Bool {
        return loggedInState == .loggedin
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

var privacyPIN = ""
var pinMax = 4

func textAsStars(_ text: String) -> String {
    var stars = ""
    for _ in 0..<text.count {
        stars = stars + "●"
    }
    if text.count < pinMax {
        for _ in text.count..<pinMax {
            stars = stars + "○"
        }
    }
    return stars
}

func textAsNumberBalls(_ text: String) -> String {
    var numberBallText = ""
    for c in text {
        if let i = Int("\(c)") {
            numberBallText = "\(numberBallText)\(numberBalls[i])"
        }
    }
    if text.count < pinMax {
        for _ in text.count..<pinMax {
            numberBallText = numberBallText + "○"
        }
    }
    return numberBallText
}

// Perform something after a delay
// e.g. delay(0.5) { dprint("hello") }
func delay(_ time: Double, aFunc: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + TimeInterval(time)) {
        aFunc()
    }
}

//
//  SettingsViewController.swift
//  Birdathon
//
//  Created by Barry Langdon-Lassagne on 3/29/18.
//  Copyright © 2018 Barry Langdon-Lassagne. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var pieDonutSwitch: UISwitch!
    let defaults = UserDefaults.standard
    @IBOutlet weak var chartExampleView: MlChartDrawingView!
    @IBOutlet weak var privacyScreenSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(noticeBroughtToForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noticeBroughtToForeground(_:)), name: UIApplication.willResignActiveNotification, object: nil)

        pieDonutSwitch.isOn = PieOrDonut.donut()
        privacyScreenSwitch.isOn = defaults.bool(forKey: kPrivacyScreenKey)
        // Populate the chartExampleView
        chartExampleView.circumference = 30.0
        chartExampleView.categoryCounts = [love:3, joy:3, surprise:3, fear:3, anger:3, sadness:3]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showPrivacyScreenIfNeeded()
    }
    
    @objc func noticeBroughtToForeground(_ sender: Any) {
        showPrivacyScreenIfNeeded()
    }
    
    func showPrivacyScreenIfNeeded() {
        if let delegate = UIApplication.shared.delegate as? MlAppDelegate {
            if delegate.loggedIn == false && delegate.showPrivacyScreen == true {
                self.performSegue(withIdentifier: "showPrivacyScreen", sender: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func togglePieOrDonut(_ sender: Any) {
        pieOrDonutChart = pieDonutSwitch.isOn
        defaults.set(pieOrDonutChart, forKey: kPieOrDonutChartKey)
        defaults.synchronize()
        chartExampleView.setNeedsDisplay()
    }
    
    @IBAction func togglePrivacyScreen(_ sender: Any) {
        if privacyScreenSwitch.isOn {
            showPrivacyViewController(self)
        }
        else {
            hidePrivacyViewController(self)
        }
    }
    
    func wasCompleted() {
        if let appDelegate = (UIApplication.shared.delegate as? MlAppDelegate) {
            appDelegate.loggedIn = privacyScreenSwitch.isOn // Initial state
            appDelegate.showPrivacyScreen = privacyScreenSwitch.isOn
            defaults.set(appDelegate.showPrivacyScreen, forKey: kPrivacyScreenKey)
            defaults.synchronize()
        }
    }

    func wasCanceled() {
        privacyScreenSwitch.isOn = !privacyScreenSwitch.isOn
        if privacyScreenSwitch.isOn { // If it was canceled when on, show the privacy screen
            if let delegate = UIApplication.shared.delegate as? MlAppDelegate {
                delegate.showPrivacyScreen = true
            }
        }
        if let appDelegate = (UIApplication.shared.delegate as? MlAppDelegate) {
            appDelegate.showPrivacyScreen = privacyScreenSwitch.isOn
            defaults.set(appDelegate.showPrivacyScreen, forKey: kPrivacyScreenKey)
            defaults.synchronize()
        }
    }

    @IBAction func showPrivacyViewController(_ sender: Any) {
        let sb = UIStoryboard(name: "PrivacyScreen", bundle: nil)
        if let pinVC = sb.instantiateViewController(withIdentifier: "pinViewController") as? PrivacySetterViewController {
            pinVC.modalPresentationStyle = .fullScreen
            pinVC.labelText = "Choose a code"
            pinVC.newPIN = true
            pinVC.settingsVC = self
            self.present(pinVC, animated: true, completion:  {
                print("Completed from show")
            })
        }
    }
    
    @IBAction func hidePrivacyViewController(_ sender: Any) {
        let sb = UIStoryboard(name: "PrivacyScreen", bundle: nil)
        if let pinVC = sb.instantiateViewController(withIdentifier: "pinViewController") as? PrivacySetterViewController {
            pinVC.modalPresentationStyle = .fullScreen
            pinVC.labelText = "Enter code to disable Privacy Screen"
            pinVC.newPIN = false
            pinVC.settingsVC = self
           self.present(pinVC, animated: true, completion: {
                print("Completed from hide.")
            })
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pieDonutSwitch.isOn = PieOrDonut.donut()
        // Populate the chartExampleView
        chartExampleView.circumference = 30.0
        chartExampleView.categoryCounts = [love:3, joy:3, surprise:3, fear:3, anger:3, sadness:3]
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

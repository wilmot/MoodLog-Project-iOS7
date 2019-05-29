//
//  PrivacySetterViewController.swift
//  Mood-Log
//
//  Created by Barry Langdon-Lassagne on 5/22/19.
//  Copyright © 2019 Barry A. Langdon-Lassagne. All rights reserved.
//

import UIKit

class PrivacySetterViewController: UIViewController {
    var labelText: String = ""
    var newPIN: Bool = true
    var canceled: Bool = false
    var settingsVC: SettingsViewController?
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var codeText = ""
    var firstCodeText = ""
    
    override public var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    @IBAction func tapPINButton(_ sender: RoundedButton) {
        sender.click()
        if let text = sender.titleLabel?.text {
            guard let num = Int(text) else { return }
            codeText = "\(codeText)\(num)"
            updatePINText(codeText)
            if codeText.count >= 4 {
                delay(0.5) {
                    if self.firstCodeText == "" {
                        if self.newPIN {
                            self.topLabel.text = "Verify your code"
                            self.firstCodeText = self.codeText
                            self.codeText = ""
                        }
                        else {
                            let pin = UserDefaults.standard.string(forKey: kPrivacyPINDefault)
                            if self.codeText == pin {
                                if let settingsVC = self.settingsVC {
                                    settingsVC.wasCompleted()
                                }
                                self.dismiss(animated: true, completion: nil)
                            }
                            else {
                                self.topLabel.text = "Try again"
                                self.codeText = ""
                            }
                        }
                    }
                    else {
                        if self.codeText == self.firstCodeText {
                            self.topLabel.text = "Code set"
                            // Save new code here
                            let newPINObject = self.codeText
                            UserDefaults.standard.set(newPINObject, forKey: kPrivacyPINDefault)
                            self.firstCodeText = ""
                            self.codeText = ""
                            delay(0.5) {
                                if let settingsVC = self.settingsVC {
                                    settingsVC.wasCompleted()
                                }
                               self.dismiss(animated: true, completion: nil)
                            }
                        }
                        else {
                            self.topLabel.text = "Codes don't match. Please start over."
                            self.firstCodeText = ""
                            self.codeText = ""
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func tapCancel(_ sender: Any) {
        if let settingsVC = settingsVC {
            settingsVC.wasCanceled()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapDelete(_ sender: Any) {
        codeText = String(codeText.dropLast())
        updatePINText(codeText)
    }
    
    func updatePINText(_ text: String) {
        if self.newPIN {
            topLabel.text = textAsNumberBalls(text)
        }
        else {
            topLabel.text = textAsStars(text)
        }
        deleteButton.isHidden = (codeText == "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        topLabel.text = labelText
        deleteButton.isHidden = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

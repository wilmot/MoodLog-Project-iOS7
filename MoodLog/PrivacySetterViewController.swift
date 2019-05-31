//
//  PrivacySetterViewController.swift
//  Mood-Log
//
//  Created by Barry Langdon-Lassagne on 5/22/19.
//  Copyright © 2019 Barry A. Langdon-Lassagne. All rights reserved.
//

import UIKit
import LocalAuthentication

class PrivacySetterViewController: UIViewController {
    var labelText: String = ""
    var newPIN: Bool = true
    var settingsVC: SettingsViewController?
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var disableWithPasscodeButton: UIButton!
    
    var codeText = ""
    var firstCodeText = ""
    var failedDisableAttempts = 0
    
    override public var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    @IBAction func tapPINButton(_ sender: RoundedButton) {
        sender.click()
        if let text = sender.titleLabel?.text {
            guard let num = Int(text) else { return }
            if codeText.count < pinMax {
                codeText = "\(codeText)\(num)"
                updatePINText(codeText)
            }
            if codeText.count == pinMax {
                if self.firstCodeText == "" {
                    if self.newPIN {
                        self.firstCodeText = codeText
                        self.codeText = ""
                        delay(0.5) {
                            if self.codeText == "" {
                                self.topLabel.text = "Verify your code"
                            }
                        }
                    }
                    else { // Turning off the PIN
                        let pin = UserDefaults.standard.string(forKey: kPrivacyPINDefault)
                        if codeText == pin {
                            if let settingsVC = self.settingsVC {
                                settingsVC.wasCompleted()
                            }
                            delay(0.5) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                        else {
                            self.topLabel.text = "Try again"
                            self.codeText = ""
                            failedDisableAttempts += 1
                            if failedDisableAttempts >= 3 {
                                disableWithPasscodeButton.isHidden = false
                            }
                        }
                    }
                }
                else {
                    if codeText == self.firstCodeText {
                        // Save new code here
                        let newPINObject = codeText
                        UserDefaults.standard.set(newPINObject, forKey: kPrivacyPINDefault)
                        self.firstCodeText = ""
                        self.codeText = ""
                        delay(0.2) {
                            self.topLabel.text = "Code set"
                            delay(0.75) {
                                if let settingsVC = self.settingsVC {
                                    settingsVC.wasCompleted()
                                }
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                    else {
                        print("code: \(self.codeText), first code: \(self.firstCodeText)")
                        self.topLabel.text = "Codes don't match. Please start over."
                        self.firstCodeText = ""
                        self.codeText = ""
                    }
                }
            }
            else {
                // print("Typed too many digits.")
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

    /// An authentication context stored at class scope so it's available for use during UI updates.
    var context = LAContext()
    @IBAction func tapDisableWithPasscode(_ sender: Any) {
        // Get a fresh context for each login. If you use the same context on multiple attempts
        //  (by commenting out the next line), then a previously successful authentication
        //  causes the next policy evaluation to succeed without testing biometry again.
        //  That's usually not what you want.
        
        if #available(iOS 10.0, *) {
            context.localizedCancelTitle = "Cancel"
        } else {
            // Fallback on earlier versions
            print("Falling back")
        }
        
        // First check if we have the needed hardware support.
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            
            let reason = "Disable Mood-Log Privacy Screen"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                
                if success {
                    // Move to the main thread because a state update triggers UI changes.
                    DispatchQueue.main.async { [unowned self] in
                        if let settingsVC = self.settingsVC {
                            settingsVC.wasCompleted()
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                } else {
                    print(error?.localizedDescription ?? "Failed to authenticate")
                    // Fall back to a asking for username and password.
                    // ...
                }
            }
        } else {
            print(error?.localizedDescription ?? "Can't evaluate policy")
            // Fall back to a asking for username and password.
            // ...
        }
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
        context = LAContext()
        disableWithPasscodeButton.isHidden = true
        if let appDelegate = (UIApplication.shared.delegate as? MlAppDelegate) {
            appDelegate.showPrivacyScreen = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        if #available(iOS 11.0, *) {
            if context.biometryType == .faceID {
                disableWithPasscodeButton.setTitle("Disable with FaceID", for: .normal)
            }
        }
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

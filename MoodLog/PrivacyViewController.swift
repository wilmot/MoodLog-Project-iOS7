/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Login view controller.
*/

import UIKit
import LocalAuthentication

@objc public class PrivacyViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var faceIDLabel: UILabel!
    @IBOutlet var pinButtons: [RoundedButton]!
    @IBOutlet weak var pinLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var pinText = ""
    
    override public var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    /// An authentication context stored at class scope so it's available for use during UI updates.
    var context = LAContext()

    @IBAction func tapPINButton(_ sender: RoundedButton) {
        sender.click()
        if let text = sender.titleLabel?.text {
            pinText = pinText + text
            updatePINText()
        }
    }
    
    @IBAction func tapDelete(_ sender: Any) {
        pinText = String(pinText.dropLast())
        updatePINText()
    }
    
    func textAsStars(text: String) -> String {
        var stars = ""
        for _ in 0..<text.count {
            stars = stars + "●"
        }
        for _ in text.count..<pinMax {
            stars = stars + "○"
        }
        return stars
    }
    
    func updatePINText() {
        pinLabel.text = textAsStars(text: pinText)
        deleteButton.isHidden = (pinText == "")
        if pinText == privacyPIN {
            print("Success!")
            clearPIN(success: true, animation: false)
            // Move to the main thread because a state update triggers UI changes.
        }
        if pinText.count >= pinMax {
            clearPIN(success: false, animation: true)
        }
    }
    
    func animatePIN(_ offset: CGFloat) {
        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: [.curveEaseInOut],
                       animations: {
                        self.pinLabel.center = CGPoint(x: self.pinLabel.center.x - offset, y: self.pinLabel.center.y)
        },
                       completion: { finished in
                        UIView.animate(withDuration: 0.1,
                                       delay: 0.0,
                                       options: [.curveEaseInOut],
                                       animations: {
                                        self.pinLabel.center = CGPoint(x: self.pinLabel.center.x + offset*2, y: self.pinLabel.center.y)
                        },
                                       completion: { finished in
                                        UIView.animate(withDuration: 0.04,
                                                       delay: 0.0,
                                                       options: [.curveEaseInOut],
                                                       animations: {
                                                        self.pinLabel.center = CGPoint(x: self.pinLabel.center.x - offset, y: self.pinLabel.center.y)
                                        },
                                                       completion: { finished in
                                                        UIView.animate(withDuration: 0.08,
                                                                       delay: 0.0,
                                                                       options: [.curveEaseInOut],
                                                                       animations: {
                                                                        self.pinLabel.center = CGPoint(x: self.pinLabel.center.x - offset*0.6, y: self.pinLabel.center.y)
                                                        },
                                                                       completion: { finished in
                                                                        UIView.animate(withDuration: 0.08,
                                                                                       delay: 0.0,
                                                                                       options: [.curveEaseInOut],
                                                                                       animations: {
                                                                                        self.pinLabel.center = CGPoint(x: self.pinLabel.center.x + offset*2*0.6, y: self.pinLabel.center.y)
                                                                        },
                                                                                       completion: { finished in
                                                                                        UIView.animate(withDuration: 0.08,
                                                                                                       delay: 0.0,
                                                                                                       options: [.curveEaseInOut],
                                                                                                       animations: {
                                                                                                        self.pinLabel.center = CGPoint(x: self.pinLabel.center.x - offset*0.6, y: self.pinLabel.center.y)
                                                                                        },
                                                                                                       completion: { finished in
                                                                                                        UIView.animate(withDuration: 0.02,
                                                                                                                       delay: 0.0,
                                                                                                                       options: [.curveEaseInOut],
                                                                                                                       animations: {
                                                                                                                        self.pinLabel.center = CGPoint(x: self.pinLabel.center.x - offset*0.2, y: self.pinLabel.center.y)
                                                                                                        },
                                                                                                                       completion: { finished in
                                                                                                                        UIView.animate(withDuration: 0.04,
                                                                                                                                       delay: 0.0,
                                                                                                                                       options: [.curveEaseInOut],
                                                                                                                                       animations: {
                                                                                                                                        self.pinLabel.center = CGPoint(x: self.pinLabel.center.x + offset*2*0.2, y: self.pinLabel.center.y)
                                                                                                                        },
                                                                                                                                       completion: { finished in
                                                                                                                                        UIView.animate(withDuration: 0.04,
                                                                                                                                                       delay: 0.0,
                                                                                                                                                       options: [.curveEaseInOut],
                                                                                                                                                       animations: {
                                                                                                                                                        self.pinLabel.center = CGPoint(x: self.pinLabel.center.x - offset*0.2, y: self.pinLabel.center.y)
                                                                                                                                        },
                                                                                                                                                       completion: { finished in
                                                                                                                                                        //
                                                                                                                                        })
                                                                                                                        })
                                                                                                        })
                                                                                        })
                                                                        })
                                                        })
                                                        
                                        })
                        })
        })
    }

    func clearPIN(success: Bool, animation: Bool) {
        pinText = ""
        delay(0.2) {
            if animation {
                self.animatePIN(20)
            }
            if success {
                DispatchQueue.main.async { [unowned self] in
                    self.state = .loggedin
                }
            }
            self.pinLabel.text = self.textAsStars(text: self.pinText)
            self.deleteButton.isHidden = (self.pinText == "")
        }
    }
    
    @objc
    func makeLoggedInState(newState: Bool) {
        if newState {
            state = .loggedin
        }
        else {
            state = .loggedout
        }
    }
    
    /// The current authentication state.
    var state = AuthenticationState.loggedout {

        // Update the UI on a change.
        didSet {
            // ((MlAppDelegate *)[UIApplication sharedApplication].delegate)
            if let appDelegate = (UIApplication.shared.delegate as? MlAppDelegate) {
                appDelegate.loggedIn = state == .loggedin
            }
            loginButton.isHighlighted = state == .loggedin  // The button text changes on highlight.
            stateView.backgroundColor = state == .loggedin ? .white : .white
            controlsView.backgroundColor = state == .loggedin ? .white : .white

            // FaceID runs right away on evaluation, so you might want to warn the user.
            //  In this app, show a special Face ID prompt if the user is logged out, but
            //  only if the device supports that kind of authentication.
            if #available(iOS 11.0, *) {
                faceIDLabel.isHidden = (state == .loggedin) || (context.biometryType != .faceID)
            } else {
                // Fallback on earlier versions
                faceIDLabel.isHidden = true
            }
            if state == .loggedout {
                pinLabel.isHidden = false
            }
            else {
                pinLabel.isHidden = true
            }
            if state == .loggedin {
                self.performSegue(withIdentifier: "unwindTest", sender: self)
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // The biometryType, which affects this app's UI when state changes, is only meaningful
        //  after running canEvaluatePolicy. But make sure not to run this test from inside a
        //  policy evaluation callback (for example, don't put next line in the state's didSet
        //  method, which is triggered as a result of the state change made in the callback),
        //  because that might result in deadlock.
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)

        // Set the initial app state. This impacts the initial state of the UI as well.
        state = .loggedout
        pinLabel.text = ""
        updatePINText()
        deleteButton.isHidden = true
    }

    /// Logs out or attempts to log in when the user taps the button.
    @IBAction func tapButton(_ sender: UIButton) {

        if state == .loggedin {
            // Log out immediately.
            state = .loggedout
        } else {
            // Get a fresh context for each login. If you use the same context on multiple attempts
            //  (by commenting out the next line), then a previously successful authentication
            //  causes the next policy evaluation to succeed without testing biometry again.
            //  That's usually not what you want.
            context = LAContext()

            if #available(iOS 10.0, *) {
                context.localizedCancelTitle = "Cancel"
            } else {
                // Fallback on earlier versions
                print("Falling back")
            }

            // First check if we have the needed hardware support.
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {

                let reason = "Unlock Mood-Log"
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in

                    if success {
                        // Move to the main thread because a state update triggers UI changes.
                        DispatchQueue.main.async { [unowned self] in
                            self.state = .loggedin
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
    }
}


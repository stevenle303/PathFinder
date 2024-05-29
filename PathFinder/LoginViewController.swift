//
//  LoginViewController.swift
//  PathFinder
//
//  Created by Hensanity Le on 11/15/22.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func onSignIn(_ sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password)
        { (user, error) in
            if user != nil {
                self.errorLabel.text = ""
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }else{
                self.errorLabel.text = error?.localizedDescription
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        
        user.signUpInBackground { (success, error) in
            if success {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                self.errorLabel.text = ""
            } else {
                self.errorLabel.text = error?.localizedDescription
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
        /*
         @IBAction func OnSignUp(_ sender: Any) {
         }
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    }
}

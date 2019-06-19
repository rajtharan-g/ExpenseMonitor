//
//  ViewController.swift
//  Personal Expense Tracker
//
//  Created by Vyshak Athreya B K on 12/20/17.
//  Copyright © 2017 Vyshak Athreya B K. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signIn: UIButton!
    
    @IBOutlet weak var loginView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeSpinner()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.loginView.endEditing(true)
    }
    
    @IBAction func back(unwindSegue:UIStoryboardSegue) {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField{
            textField.resignFirstResponder()
            actionSignIn(" ")
            self.loginView.endEditing(true)
        }
        return true
    }
    
    func showAlert() {
        let alert = UIAlertController(title: nil, message: "Incorrect email or password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func actionSignIn(_ sender: Any) {
        if let mail = emailTextField.text , let pass = passwordTextField.text
        {
            self.showSpinner(onView: self.view, style: .gray)
            Auth.auth().signIn(withEmail: mail, password: pass, completion: {
               (user,error) in
                self.removeSpinner()
                if user != nil{
                    UserDefaults.standard.setValue(true, forKey: "sign_in")
                    UserDefaults.standard.synchronize()
                    self.performSegue(withIdentifier: "MainScreen", sender: self)
                }
                else
                {
                    if let myerr = error?.localizedDescription{
                        print(myerr)
                        self.showAlert()
                    }
                }
            })
        }
    }
    
    @IBAction func actionTermsAndConditions(_ sender: Any) {
        guard let url = URL(string: "https://google.com") else { return }
        UIApplication.shared.open(url)
    }
    
}


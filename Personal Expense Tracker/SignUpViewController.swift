//
//  SignUpViewController.swift
//  Personal Expense Tracker
//
//  Created by Vyshak Athreya B K on 12/20/17.
//  Copyright © 2017 Vyshak Athreya B K. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import SkyFloatingLabelTextField

class SignUpViewController: UIViewController ,UIPickerViewDataSource,UIPickerViewDelegate, UITextFieldDelegate{
    
    let rootRef = Database.database().reference()
    var currencyArray = Array<String>()
    var currencyChosen = "USD($)"
    var problemFlag = true
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var SignInButton: UIButton!
    
    @IBOutlet weak var formView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let data:Bundle = Bundle.main
        let currencyPlist:String? = data.path(forResource: "Currency", ofType: "plist")
        if currencyPlist != nil
        {
            currencyArray = NSArray(contentsOfFile: currencyPlist!) as! [String]
        }
        nameTextField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingChanged)
        phoneTextField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingChanged)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.formView.endEditing(true)
    }
    
    @IBAction func SignUpAction(_ sender: Any) {
        if self.problemFlag == false{
            //self.status.isHidden = true
            createNewUser()
        }
        if self.problemFlag == true{
            //self.status.isHidden = false
            //self.status.text = "All fields are required"
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currencyChosen =  currencyArray[row]
    }
    
    func editDidEnd() {
        self.formView.endEditing(true)
    }
    
    @IBAction func passwordDidEnd(_ sender: UITextField) {
        if (sender.text?.count)! < 6{
            self.problemFlag = true
//            self.passwordError.isHidden = false
//            self.passwordError.text = "\u{26A0} Minimum 6 characters"
            self.problemFlag = true
        }else if (sender.text?.isEmpty)!{
            self.problemFlag = true
//            self.passwordError.isHidden = false
//            self.passwordError.text = "\u{26A0} Please enter password"
            }
        else{
            //self.passwordError.isHidden = true
            self.problemFlag = false
        }
    }
    
    @IBAction func phoneDidEnd(_ sender: UITextField) {
        if (sender.text?.count)! < 10{
            self.problemFlag = true
//            self.phoneError.isHidden = false
//            self.phoneError.text = "\u{26A0} Number seems incorrect"
            self.problemFlag = true
        }else if (sender.text?.isEmpty)!{
            self.problemFlag = true
//            self.phoneError.isHidden = false
//            self.phoneError.text = "\u{26A0} Phone number is required"
        }else{
            //self.phoneError.isHidden = true
            self.problemFlag = false
        }
    }
    
    @IBAction func nameDidEnd(_ sender: UITextField) {
        if (sender.text?.isEmpty)!{
            self.problemFlag = true
//            self.nameError.isHidden = false
//            self.nameError.text = "\u{26A0} Name is required"
        }else{
            //self.nameError.isHidden = true
            self.problemFlag = false
        }
    }
    
    @IBAction func emailDidEnd(_ sender: UITextField) {
        if (sender.text?.isEmpty)!{
            self.problemFlag = true
//            self.emailError.isHidden = false
//            self.emailError.text = "\u{26A0} Email id is required"
        }else{
            //self.emailError.isHidden = true
            self.problemFlag = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField{
            emailTextField.becomeFirstResponder()
        }
        if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }
        if textField == phoneTextField{
            textField.resignFirstResponder()
            self.formView.endEditing(true)
        }
        if textField == passwordTextField{
            phoneTextField.becomeFirstResponder()
        }
        return true
    }
    
    func createNewUser(){
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: {
            (user,error) in
            if let userfound = user{
                let changeRequest = userfound.createProfileChangeRequest()
                changeRequest.displayName = self.nameTextField.text!
                changeRequest.commitChanges { error in
                    if error != nil {
                        self.showAlert()
                    } else {
                        let userRoot = self.rootRef.child("users/" + userfound.uid)
                        userRoot.child("email").setValue(self.emailTextField.text!)
                        userRoot.child("name").setValue(self.nameTextField.text!)
                        userRoot.child("phone").setValue(self.phoneTextField.text)
                        userRoot.child("currency").setValue(self.currencyChosen)
                        userRoot.child("uid").setValue(userfound.uid)
                        self.performSegue(withIdentifier: "NewUser", sender: self)
                    }
                }
            }
            else
            {
                self.showAlert()
                if let myerr = error?.localizedDescription
                {
                    print("This was wrong",myerr)
                }else{
                    print("Error")
                }
            }
        })
    }
    
    @IBAction func showAlert() {
        let alert = UIAlertController(title: "Account Exists!", message: "Please login using email and password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // This will notify us when something has changed on the textfield
    @objc func textFieldDidEndEditing(_ textfield: UITextField) {
        if textfield == emailTextField {
            if let text = textfield.text {
                if let floatingLabelTextField = textfield as? SkyFloatingLabelTextField {
                    if (text.count < 3 || !text.contains("@")) {
                        floatingLabelTextField.errorMessage = "Invalid email"
                    } else {
                        // The error message will only disappear when we reset it to nil or empty string
                        floatingLabelTextField.errorMessage = ""
                    }
                }
            }
        } else if textfield == nameTextField {
            if let text = textfield.text {
                if let floatingLabelTextField = textfield as? SkyFloatingLabelTextField {
                    if (text.count <= 0) {
                        floatingLabelTextField.errorMessage = "\u{26A0} Name is required"
                    } else {
                        // The error message will only disappear when we reset it to nil or empty string
                        floatingLabelTextField.errorMessage = ""
                    }
                }
            }
        } else if textfield == passwordTextField {
            if let text = textfield.text {
                if let floatingLabelTextField = textfield as? SkyFloatingLabelTextField {
                    if (text.count < 6) {
                        floatingLabelTextField.errorMessage = "\u{26A0} Minimum 6 characters"
                    } else {
                        // The error message will only disappear when we reset it to nil or empty string
                        floatingLabelTextField.errorMessage = ""
                    }
                }
            }
        } else if textfield == phoneTextField {
            if let text = textfield.text {
                if let floatingLabelTextField = textfield as? SkyFloatingLabelTextField {
                    if (text.count < 10) {
                        floatingLabelTextField.errorMessage = "\u{26A0} Number seems incorrect"
                    } else {
                        // The error message will only disappear when we reset it to nil or empty string
                        floatingLabelTextField.errorMessage = ""
                    }
                }
            }
        }
    }
    
}



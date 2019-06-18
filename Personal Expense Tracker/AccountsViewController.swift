//
//  AccountsViewController.swift
//  Personal Expense Tracker
//
//  Created by Vyshak Athreya B K on 12/21/17.
//  Copyright © 2017 Vyshak Athreya B K. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import HGPlaceholders

class AccountsViewController: UIViewController, UIPickerViewDelegate,UITextFieldDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    var accName:String = " "
    var userRoot:DatabaseReference!
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var accNameTextField: UITextField!
    @IBOutlet weak var accountsTableView: TableView!
    //@IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var accountView: UIView!
    
    let types: [String] = ["Saving","Credit Card"]
    var accType:String!
    var accNames = Array<Dictionary<String, Any>>()
    var accTypes = Array<String>()
    var accArr = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountsTableView.dataSource = self
        accountsTableView.delegate = self
        let user = Auth.auth().currentUser?.displayName
        accType = types[0]
        userRoot = Database.database().reference().child("accounts/"+user!)
        getData()
        accountsTableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeSpinner()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return types[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        accType = types[row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accArr.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let accountSelected = accArr[indexPath.row]
        let askUser = UIAlertController(title: accountSelected, message:"Remove this account?",preferredStyle:.alert)
        askUser.addAction(UIAlertAction(title: "Remove", style: .default, handler:  {UIAlertAction in self.userRoot.child(accountSelected).removeValue()}))
        askUser.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(askUser, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "accounts")
        cell.textLabel?.text = (self.accArr[indexPath.row] )
        return cell
    }
    
    func getData(){
        accountsTableView.showLoadingPlaceholder()
        userRoot.observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary{
                self.accArr.removeAll()
                for (key,_) in value{
                    self.accArr.append(key as! String)
                    self.accountsTableView.reloadData()
                }
            } else{
                self.accountsTableView.showNoResultsPlaceholder()
            }
            if self.accArr.count == 0 {
                self.accountsTableView.showNoResultsPlaceholder()
            }
        })
    }
    
    @IBAction func addAccountAction(_ sender: Any) {
        accName = accNameTextField.text!
        if accName != " "{
            let account = accName + "-" + accType
            userRoot.child(account).child("accountName").setValue(accName)
            userRoot.child(account).child("accountType").setValue(accType)
        }else{
            self.alertUser()
        }
        getData()
        accNameTextField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.accountView.endEditing(true)
        if (textField.text?.isEmpty)!{
            alertUser()
        }else{
        addAccountAction("")
        }
        return true
    }
    
    func editDidEnd() {
        self.accountView.endEditing(true)
    }
    
    @IBAction func alertUser() {
        let alert = UIAlertController(title: "No Data!", message: "Account nick name is required", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.accountView.endEditing(true)
    }
}



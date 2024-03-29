//
//  DashBoardViewController.swift
//  Personal Expense Tracker
//
//  Created by Vyshak Athreya B K on 12/21/17.
//  Copyright © 2017 Vyshak Athreya B K. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import Alamofire
import HGPlaceholders

class DashBoardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var transactionTableView: TableView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var baseCurrencyLabel: UILabel!
    @IBOutlet weak var baseBalanceLabel: UILabel!
    //@IBOutlet weak var messageUILabel: UILabel!
    
    var userRoot:DatabaseReference!
    var expense:Double = 0.0
    var income:Double = 0.0
    var user:String!
    var uid:String!
    var symbol:String = " "
    var userCurrency:String = " "
    var accountSums = [String: Double]()

    var transactionArray = Array<String>()
    var accountArray = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uid = Auth.auth().currentUser?.uid
        user = Auth.auth().currentUser?.displayName
        userRoot = Database.database().reference().child("transactions/"+uid!)
        user = Auth.auth().currentUser?.displayName
        transactionTableView.tableFooterView = UIView()
        transactionTableView.placeholdersProvider =  PlaceholdersProvider(loading: .fetchingYourAccounts, error: .errorFetchingYourData, noResults: .noAccountAdded(withAction: NSLocalizedString("OK!", comment: "")), noConnection: .noInternetConnection)
        transactionTableView.placeholderDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeSpinner()
    }
    
    func getData(){
        userRoot.observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary{
                self.transactionArray.removeAll()
                self.income = 0.0
                self.expense = 0.0
                for (_,val) in value{
                    let jscon = JSON.init(val)
                    var doubleAmount = 0.0
                    if let amount = jscon["amount"].string, let acc = jscon["account"].string,
                        let categ = jscon["category"].string, let _ = self.accountSums[acc] {
                        doubleAmount = Double(amount)!
                        if (categ == "Income"){
                            self.income += doubleAmount
                            self.accountSums[acc]! = self.accountSums[acc]! + doubleAmount
                        } else {
                            self.expense += doubleAmount
                            self.accountSums[acc]! = self.accountSums[acc]! - doubleAmount
                        }
                        self.transactionTableView.reloadData()
                    }
                    self.balanceLabel.text = String(self.income - self.expense)
                }
                for (key,value) in self.accountSums{
                    self.transactionArray.append(key + " : " + String(value))
                }
                self.transactionTableView.reloadData()
            } else
            {
                print("error.localizedDescription")
            }
            if self.transactionArray.count == 0 {
                self.transactionTableView.showNoResultsPlaceholder()
            }
            self.getCurrencyRate()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionArray.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "accounts")
        cell.textLabel?.text = self.transactionArray[indexPath.row]
        return cell
    }
    
    func getUserData(){
        transactionTableView.showLoadingPlaceholder()
        let accountRoot = Database.database().reference().child("accounts/"+user!)
        accountRoot.observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary{
                //self.messageUILabel.isHidden = true
                self.accountArray.removeAll()
                for (key,_) in value{
                    self.accountArray.append(key as! String)
                    self.accountSums[key as! String] = 0
                }
            }else{
                //self.messageUILabel.isHidden = false
                //self.messageUILabel.text = "Please add accounts"
                self.transactionTableView.showNoResultsPlaceholder() // Please add acccount
            }
            self.getData()
        })
    }
    
    func getCurrencyRate(){
        let user = Auth.auth().currentUser
        let currencyRef = Database.database().reference().child("users/" + (user?.uid)!)
        currencyRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let curr = value?["currency"] as? String ?? ""
            self.symbol = curr
            let substr = curr.split(separator: "(", maxSplits: 3, omittingEmptySubsequences: true)
            self.userCurrency = String(substr[0])
            let stateRequest = "http://data.fixer.io/api/latest?access_key=74eef4c28738ef25a9d633c57bc14078"
            Alamofire.request(stateRequest).validate()
                .responseJSON
                {
                    response in
                    switch response.result
                    {
                    case .success(let curr):
                        let json = JSON(curr)
                        let ratesDict = json["rates"].dictionary
                        let rate = ratesDict?[self.userCurrency]?.double //edits while grading
                        if self.userCurrency != "USD"{
                            self.baseBalanceLabel.isHidden = false
                            self.baseCurrencyLabel.isHidden = false
                            self.baseCurrencyLabel.text = self.symbol
                            self.baseBalanceLabel.text = String((rate ?? 0) * (self.income - self.expense))
                        }else{
                            self.baseBalanceLabel.isHidden = true
                            self.baseCurrencyLabel.isHidden = false
                        }
                    case .failure(let error):
                        print(error)
                    }
        }
        })
    }
    
}

extension DashBoardViewController: PlaceholderDelegate {
    
    func view(_ view: Any, actionButtonTappedFor placeholder: Placeholder) {
        
    }
    
}

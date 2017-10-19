//
//  ViewReputationVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 19/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum ReputationType {
    case All
    case Sharrie
    case Sharror
}

class ViewReputationVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var reputation: [Reputation] = []
    
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var sharrieBtn: UIButton!
    @IBOutlet weak var sharrorBtn: UIButton!
    
    var reputationType: ReputationType = .All
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupBtnUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // For Hiding away empty cell
        
        getAllReputation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupBtnUI() {
        allBtn.layer.borderColor = Colours.Blue.sharritBlue.cgColor
        allBtn.layer.borderWidth = 1
        currentBtnSelected(btn: allBtn)
        sharrieBtn.layer.borderColor = Colours.Blue.sharritBlue.cgColor
        sharrieBtn.layer.borderWidth = 1
        sharrorBtn.layer.borderColor = Colours.Blue.sharritBlue.cgColor
        sharrorBtn.layer.borderWidth = 1
    }
    
    func currentBtnSelected(btn: UIButton) {
        btn.backgroundColor = Colours.Blue.sharritBlue
        btn.setTitleColor(UIColor.white, for: .normal)
    }
    
    func defaultBtnUI() {
        allBtn.backgroundColor = UIColor.white
        allBtn.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
        sharrieBtn.backgroundColor = UIColor.white
        sharrieBtn.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
        sharrorBtn.backgroundColor = UIColor.white
        sharrorBtn.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
    }
    
    func getAllReputation() {
        let url: String!
        
        switch reputationType {
        case .All:
            // MUST TODO: Waiting for Joe
            url = SharritURL.devURL + "conversation/user/" + String(describing: appDelegate.user!.userID)
            break
        case .Sharrie:
            // Get All Reputation for Me (Sharrie) by other Sharror/Sharing Business
            url = SharritURL.devURL + "reputation/sharrie/other/" + String(describing: appDelegate.user!.userID)
            break
        case .Sharror:
            // Get All Reputation for Me (Sharror) by other Sharrie
            url = SharritURL.devURL + "reputation/sharror/other/" + String(describing: appDelegate.user!.userID)
            break
        }
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    self.reputation.removeAll()
                    for (_, subJson) in JSON(data) {
                        
                    }
                    self.tableView.reloadData()
                }
                break
            case .failure(_):
                print("Get Reputation API failed")
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reputation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessageTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @IBAction func overallBtnPressed(_ sender: UIButton) {
        reputationType = .All
        defaultBtnUI()
        currentBtnSelected(btn: allBtn)
        getAllReputation()
    }
    
    @IBAction func sharrieBtnPressed(_ sender: UIButton) {
        reputationType = .Sharrie
        defaultBtnUI()
        currentBtnSelected(btn: sharrieBtn)
        getAllReputation()
    }
    
    @IBAction func sharrorBtnPressed(_ sender: UIButton) {
        reputationType = .Sharror
        defaultBtnUI()
        currentBtnSelected(btn: sharrorBtn)
        getAllReputation()
    }

}

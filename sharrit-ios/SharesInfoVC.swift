//
//  SharesInfoVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 20/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Cosmos

class SharesInfoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Pass over value
    var businessInfo: Business!
    var categoryID: Int!
    var categoryName: String!
    
    @IBOutlet weak var businessBanner: UIImageView!
    @IBOutlet weak var businessLogo: UIImageView!
    @IBOutlet weak var businessName: UILabel!
    @IBOutlet weak var businessRating: CosmosView!
    @IBOutlet weak var businessStartDate: UILabel!
    @IBOutlet weak var joinSharrorBtn: SharritButton!
    @IBOutlet weak var pendingApprovalBtn: SharritButton!
    @IBOutlet weak var createSharreBtn: SharritButton!
    
    @IBOutlet weak var tableView: UITableView!
    let tableViewSection = ["Description", "Reviews"]
    var review:[String] = []
    var tableViewItems:[[String]] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = businessInfo.businessName
        
        ImageDownloader().imageFromServerURL(urlString: SharritURL.devPhotoURL + businessInfo.bannerURL, imageView: businessBanner)
        
        ImageDownloader().imageFromServerURL(urlString: SharritURL.devPhotoURL + businessInfo.logoURL, imageView: businessLogo)
        
        businessName.text = businessInfo.businessName
        
        // Get Business profile creation date
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+08")! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let currentDate = Date()
        let currentDateString = dateFormatter.string(from: currentDate)
        let todayDate = dateFormatter.date(from: currentDateString)
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        let endDate = dateFormatter2.date(from: businessInfo.dateCreated)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .weekOfMonth]
        formatter.unitsStyle = .full
        businessStartDate.text = formatter.string(from: endDate!, to: todayDate!)

        tableViewItems.append([businessInfo.description!])
        
        businessRating.rating = 1
        businessRating.settings.totalStars = 1
        if businessInfo.rating != -1 {
            businessRating.text = String(format: "%.2f", arguments: [businessInfo.rating])
            for (_, subJson) in JSON(businessInfo.ratingList) {
                review.append(subJson[
                    "review"]["message"].description)
            }
            tableViewItems.append(review)
        } else {
            businessRating.text = "No Ratings Yet"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        createSharreBtn.isHidden = true
        joinSharrorBtn.isHidden = true
        pendingApprovalBtn.isHidden = true
        
        // Get Latest Pending/Join Business
        getLatestBusinessInfo()
    }
    
    // Set up Table View - Description and Reviews
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewSection[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewSection.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && review.count == 0 {
            return 0
        } else {
            return tableViewItems[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell") as! DescriptionTableViewCell
            cell.descriptionLabel.text = businessInfo.description
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell") as! ReviewTableViewCell
            // MUST TODO: ASK JOE TO GET REVIEWER's Name and Image STRING
            cell.profileImage.image = #imageLiteral(resourceName: "empty")
            cell.profileName.text = "Test Profile Name"
            
            cell.ratingView.rating = 1
            cell.ratingView.settings.totalStars = 1
            cell.ratingView.text = String(format: "%.2f", arguments: [JSON(businessInfo.ratingList)[indexPath.item]["ratingValue"].double!])
            cell.ratingLabel.text = review[indexPath.item]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData()
    }
    
    func getLatestBusinessInfo() {
        let url = SharritURL.devURL + "user/" + String(describing: appDelegate.user!.userID)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    for (_, subJson) in JSON(data)["content"] {
                        let joinedBusinessList = subJson["bizList"].arrayObject! as! [Int]
                        let pendingBusinessList = subJson["pendingList"].arrayObject! as! [Int]
                        
                        // This is to save to user preference
                        var userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as? [String: Any]
                        
                        for (key, _):(String, JSON) in subJson {
                            if key == "bizList" {
                                userInfoDict!["key"] = joinedBusinessList
                            } else if key == "pendingList" {
                                userInfoDict!["key"] = pendingBusinessList
                            } else {
                                userInfoDict!["key"] = subJson.stringValue
                            }
                        }
                        
                        UserDefaults.standard.set(userInfoDict, forKey: "userInfo")
                        UserDefaults.standard.synchronize()
                        
                        // This is to save to appDelegate
                        self.appDelegate.user!.joinedSBList = joinedBusinessList
                        self.appDelegate.user!.pendingSBList = pendingBusinessList
                        
                        // First check - 3rd Party Business
                        if self.businessInfo.businessType == 1 {
                            self.navigationItem.rightBarButtonItem = nil
                            // Second check - If User already joined business or pending
                            if (self.appDelegate.user?.joinedSBList.contains(self.businessInfo.businessId))! {
                                self.createSharreBtn.isHidden = false
                                
                                let navBarQuit = UIBarButtonItem(title: "Quit", style: .plain, target: self, action: #selector(self.quitBusiness))
                                
                                self.navigationItem.rightBarButtonItem = navBarQuit
                            } else if (self.appDelegate.user?.pendingSBList.contains(self.businessInfo.businessId))! {
                                self.pendingApprovalBtn.isHidden = false
                            } else {
                                // Third check - If there is a request form
                                if self.businessInfo.requestFormID != -1 {
                                    self.joinSharrorBtn.isHidden = false
                                }
                            }
                        }
                    }
                }
                break
            case .failure(_):
                print("Get User Info API failed")
                break
            }
        }
    }
    
    // Quit Business
    func quitBusiness() {
        let alert = UIAlertController(title: "Quiting Business...", message: "Are you sure about this?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "I'm sure", style: .default, handler: { (_) in
            let url = SharritURL.devURL + "sharror/withdraw/" + String(describing: self.businessInfo.businessId!) + "/" + String(describing: self.appDelegate.user!.userID)
            
            Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                response in
                switch response.result {
                case .success(_):
                    if let index = self.appDelegate.user?.joinedSBList.index(of: self.businessInfo.businessId) {
                        self.appDelegate.user?.joinedSBList.remove(at: index)
                    }
                    self.viewWillAppear(true)
                    break
                case .failure(_):
                    print("Withdraw Business API failed")
                    break
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "submitForm" {
            if let sharrorFormVC = segue.destination as? SharrorFormVC {
                sharrorFormVC.companyName = businessInfo.businessName
                sharrorFormVC.companyId = businessInfo.businessId!
                sharrorFormVC.formStatus = .Create
            }
        } else if segue.identifier == "viewForm" {
            if let sharrorFormVC = segue.destination as? SharrorFormVC {
                sharrorFormVC.companyName = businessInfo.businessName
                sharrorFormVC.companyId = businessInfo.businessId!
                sharrorFormVC.formStatus = .View
                sharrorFormVC.requestFormId = businessInfo.requestFormID!
            }
        } else if segue.identifier == "contactBusiness" {
            if let contactBusinessVC = segue.destination as? ContactBusinessVC {
                contactBusinessVC.sharingBusinessName = businessInfo.businessName
                contactBusinessVC.sharingBusinessID = businessInfo.businessId
            }
        } else if segue.identifier == "createNewSharre" {
            if let newShareVC = segue.destination as? NewSharreVC {
                newShareVC.businessName = businessInfo.businessName
                newShareVC.businessID = businessInfo.businessId
                newShareVC.categoryID = categoryID
                newShareVC.categoryName = categoryName
            }
        } else if segue.identifier == "sharesInfo" {
            if let businessSharesVC = segue.destination as? BusinessSharesVC {
                businessSharesVC.businessID = businessInfo.businessId
                businessSharesVC.arriveFrom = .SharingBusiness
            }
        }
    }
    
}

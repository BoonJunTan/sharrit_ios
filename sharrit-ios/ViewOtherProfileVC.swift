//
//  ProfileVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 12/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Cosmos
import Photos
import Alamofire
import SwiftyJSON

class ViewOtherProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Pass Over Data
    var userID: Int!
    
    @IBOutlet weak var tableView: UITableView!
    var reputation: [Reputation] = []
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var starRating: CosmosView!
    let fakeRatingDouble = 4.7
    @IBOutlet weak var profileDate: UILabel!
    
    @IBOutlet weak var ratingFilter: UIStackView!
    var ratingFilterText: RatingView! {
        didSet {
            if ratingFilterText == .Overall {
                currentRatingFilter.text = "Overall"
            } else if ratingFilterText == .Sharrie {
                currentRatingFilter.text = "Sharrie"
            } else {
                currentRatingFilter.text = "Sharror"
            }
        }
    }
    
    @IBOutlet weak var currentRatingFilter: UILabel!
    @IBOutlet weak var currentRatingView: UIView!
    
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var sharrieBtn: UIButton!
    @IBOutlet weak var sharrorBtn: UIButton!
    var reputationType: ReputationType = .All
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // For Hiding away empty cell
        
        ratingFilter.isHidden = true
        ratingFilterText = .Overall
        let viewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewBtnTapped(tapGestureRecognizer:)))
        currentRatingView.addGestureRecognizer(viewTapGestureRecognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBtnUI()
        getProfile()
        getUserRating()
        getAllReputation()
    }
    
    func viewBtnTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        ratingFilter.isHidden = !ratingFilter.isHidden
    }
    
    func getProfile() {
        let url = SharritURL.devURL + "user/" + String(describing: userID!)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    let profileDetails = JSON(data)["content"][0]
                    self.profileLabel.text = profileDetails["firstName"].description + " " + profileDetails["lastName"].description
                    self.profileDate.text = FormatDate().compareDaysCreated(dateCreated: profileDetails["dateCreated"].description)
                    if let checkedUrl = URL(string: SharritURL.devPhotoURL + profileDetails["fileName"].description) {
                        self.downloadProfilePhoto(from: checkedUrl)
                    }
                }
                break
            case .failure(_):
                print("Get User Profile API failed")
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reputation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reputationCell") as! ReputationTableViewCell
        
        cell.profileName.text = reputation[indexPath.row].userName
        ImageDownloader().imageFromServerURL(urlString: (SharritURL.devPhotoURL + reputation[indexPath.row].userPhoto!), imageView: cell.profileImage)
        ImageDownloader().imageFromServerURL(urlString: (SharritURL.devPhotoURL + reputation[indexPath.row].sharrePhoto!), imageView: cell.sharreImage)
        
        cell.profileImage.layer.borderColor = UIColor.black.cgColor
        cell.profileImage.layer.borderWidth = 1
        cell.profileImage.layer.masksToBounds = true
        
        cell.transactionRating.rating = 1
        cell.transactionRating.settings.totalStars = 1
        cell.transactionRating.text = String(format: "%.2f", arguments: [reputation[indexPath.row].rating])
        
        cell.transactionReview.text = reputation[indexPath.row].review
        cell.transactionTitle.text = reputation[indexPath.row].sharreName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func downloadProfilePhoto(from url: URL) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                self.profileImage.image = UIImage(data: data)
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    @IBAction func ratingFilterBtnPressed(_ sender: UIButton) {
        if sender.titleLabel?.text == "Overall" {
            ratingFilterText = .Overall
        } else if sender.titleLabel?.text == "Sharrie" {
            ratingFilterText = .Sharrie
        } else {
            ratingFilterText = .Sharror
        }
        ratingFilter.isHidden = true
        getUserRating()
    }
    
    func getUserRating() {
        var url: String!
        
        if ratingFilterText == .Overall {
            url = SharritURL.devURL + "reputation/current/overall/" + String(describing: userID!)
        } else if ratingFilterText == .Sharrie {
            url = SharritURL.devURL + "reputation/current/sharrie/" + String(describing: userID!)
        } else {
            url = SharritURL.devURL + "reputation/current/sharror/" + String(describing: userID!)
        }
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    self.starRating.rating = 1
                    self.starRating.settings.totalStars = 1
                    if JSON(data)["status"] == -6 {
                        self.starRating.text = "Rating Unavailable"
                    } else {
                        self.starRating.text = String(format: "%.2f", arguments: [Double(JSON(data)["content"].description)!])
                    }
                }
                break
            case .failure(_):
                self.starRating.rating = 0
                print("Get User Combined Rating API failed")
                break
            }
        }
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
    
    func getAllReputation() {
        let url: String!
        
        switch reputationType {
        case .All:
            url = SharritURL.devURL + "reputation/user/other/" + String(describing: userID!)
            break
        case .Sharrie:
            // Get All Reputation for Specific User by other Sharror/Sharing Business
            url = SharritURL.devURL + "reputation/sharrie/other/" + String(describing: userID!)
            break
        case .Sharror:
            // Get All Reputation for Specific User by other Sharrie
            url = SharritURL.devURL + "reputation/sharror/other/" + String(describing: userID!)
            break
        }
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    self.reputation.removeAll()
                    for (_, subJson) in JSON(data)["content"] {
                        var currentReputation: Reputation!
                        
                        if subJson["reviewerInfo"]["businessId"] == nil {
                            currentReputation = Reputation(reputationID: subJson["rating"]["ratingId"].int!, userName: subJson["reviewerInfo"]["firstName"].description + " " + subJson["reviewerInfo"]["lastName"].description, rating: Double(subJson["rating"]["ratingValue"].description))
                            currentReputation.userPhoto = subJson["reviewerInfo"]["photos"][0]["fileName"].description
                        } else {
                            currentReputation = Reputation(reputationID: subJson["rating"]["ratingId"].int!, userName: subJson["reviewerInfo"]["name"].description, rating: Double(subJson["rating"]["ratingValue"].description))
                            currentReputation.userPhoto = subJson["reviewerInfo"]["logo"]["fileName"].description
                        }
                        
                        currentReputation.sharreName = subJson["sharre"]["name"].description
                        currentReputation.sharrePhoto = subJson["sharre"]["photos"][0]["fileName"].description
                        
                        currentReputation.sharreID = subJson["sharre"]["sharreId"].int!
                        
                        if let reviewMessage = subJson["rating"]["review"]["message"].description as? String {
                            if reviewMessage == "null" {
                                currentReputation.review = "No review provided."
                            } else {
                                currentReputation.review = reviewMessage
                            }
                        } else {
                            currentReputation.review = "No review provided."
                        }
                        self.reputation.append(currentReputation)
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
    
}
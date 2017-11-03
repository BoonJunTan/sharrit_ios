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
    let tableViewSection = ["Reputation Details"]
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
        getProfile()
        getUserRating()
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewSection[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return reputation.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reputation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reputationCell") as! ReputationTableViewCell
        //cell.iconLabel.text = reputation[indexPath.row]
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
    
}
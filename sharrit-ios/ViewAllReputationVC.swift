//
//  ViewAllReputationVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 19/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewAllReputationVC: UITableViewController {
    
    // Pass Over Data
    var sharreID: Int!

    var reputation = [Reputation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllReputation()
        
        tableView.tableFooterView = UIView() // For Hiding away empty cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reputation.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReputationCell", for: indexPath) as! SingleSharreReputationTableViewCell

        cell.userName.text = reputation[indexPath.row].userName
        
        cell.rating.rating = 1
        cell.rating.settings.totalStars = 1
        cell.rating.text = String(format: "%.2f", arguments: [reputation[indexPath.row].rating])
        
        cell.review.text = reputation[indexPath.row].review
        ImageDownloader().imageFromServerURL(urlString: (SharritURL.devPhotoURL + reputation[indexPath.row].userPhoto!), imageView: cell.userProfile)

        return cell
    }
    
    func getAllReputation() {
        let url = SharritURL.devURL + "reputation/owner/" + String(describing: sharreID!)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    self.reputation.removeAll()
                    for (_, subJson) in JSON(data)["content"] {
                        let currentReputation = Reputation(reputationID: subJson["rating"]["reviewId"].int, userName: "Not Given Yet", rating: subJson["rating"]["ratingValue"].double)
                        if let reviewMessage = subJson["rating"]["review"]["message"].description as? String {
                            if reviewMessage == "null" {
                                currentReputation.review = "No Review Available"
                            } else {
                                currentReputation.review = reviewMessage
                            }
                        } else {
                            currentReputation.review = "No Review Given"
                        }
                        currentReputation.userName = subJson["userName"]["firstName"].description + " " + subJson["userName"]["lastName"].description
                        currentReputation.userPhoto = subJson["userName"]["photos"][0]["fileName"].description
                        self.reputation.append(currentReputation)
                    }
                    self.tableView.reloadData()
                }
                break
            case .failure(_):
                print("Get Specific Sharre Reputation API failed")
                break
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

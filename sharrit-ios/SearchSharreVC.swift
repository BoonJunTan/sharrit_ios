//
//  SearchSharreVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 12/11/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SearchSharreVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    // Pass Over Data
    var searchText: String!

    var sharesCollection: [Shares]! = []
    
    @IBOutlet weak var sharesCollectionView: UICollectionView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getSearchResult()
    }
    
    func getSearchResult() {
        
        // Get User Rating first
        let getUserRatingURL = SharritURL.devURL + "reputation/current/sharrie/" + String(describing: appDelegate.user!.userID)
        
        Alamofire.request(getUserRatingURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    var userRating:Double = -1
                    if JSON(data)["status"] == -6 {
                        userRating = 3 // No Deposit = Middle Tier
                    } else {
                        if let rating = JSON(data)["content"].description as? Double {
                            userRating = rating
                        }
                    }
                    
                    // Based on rating get business sharre and deposit given
                    let url = SharritURL.devURL + "sharre/search/" + self.searchText
                    
                    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                        response in
                        switch response.result {
                        case .success(_):
                            self.sharesCollection = []
                            if let data = response.result.value {
                                if !JSON(data)["content"].isEmpty {
                                    self.title = self.searchText
                                    
                                    for (_, subJson) in JSON(data)["content"] {
                                        if !subJson["sharre"]["isDeleted"].bool! {
                                            let sharreId = subJson["sharre"]["sharreId"].int!
                                            let sharreName = subJson["sharre"]["name"].description
                                            let sharreDescription = subJson["sharre"]["description"].description
                                            let sharreType = subJson["sharre"]["type"].int!
                                            let sharreQty = subJson["sharre"]["qty"].int!
                                            let sharreUnit = subJson["sharre"]["unit"].int!
                                            let sharrePrice = subJson["sharre"]["price"].description
                                            
                                            var sharreDeposit: String!
                                            
                                            if userRating < 1 {
                                                sharreDeposit = subJson["sharre"]["depositOne"].description
                                            } else if userRating < 2 {
                                                sharreDeposit = subJson["sharre"]["depositTwo"].description
                                            } else if userRating < 3 {
                                                sharreDeposit = subJson["sharre"]["depositThree"].description
                                            } else if userRating < 4 {
                                                sharreDeposit = subJson["sharre"]["depositFour"].description
                                            } else {
                                                sharreDeposit = subJson["sharre"]["depositFive"].description
                                            }
                                            
                                            let sharreLocation = subJson["sharre"]["name"].description
                                            
                                            var photoArray = [String]()
                                            for (_, photoPath) in subJson["sharre"]["photos"] {
                                                photoArray.append(photoPath["fileName"].description)
                                            }
                                            
                                            let sharreDateCreated = subJson["sharre"]["name"].description
                                            let sharreOwnerType = subJson["sharre"]["ownerType"].int!
                                            let sharreOwnerId = subJson["sharre"]["ownerId"].int!
                                            let sharreIsActive = subJson["sharre"]["isActive"].boolValue
                                            
                                            let sharre = Shares(sharreId: sharreId, name: sharreName, description: sharreDescription, type: sharreType, qty: sharreQty, unit: sharreUnit, price: sharrePrice, deposit: sharreDeposit, location: sharreLocation, photos: photoArray, dateCreated: sharreDateCreated, ownerType: sharreOwnerType, ownerId: sharreOwnerId, isActive: sharreIsActive)
                                            
                                            let sharreActiveStart = subJson["sharre"]["activeStart"].description
                                            let sharreActiveEnd = subJson["sharre"]["activeEnd"].description
                                            
                                            if sharreActiveStart != "00:00:00" && sharreActiveEnd != "00:00:00" {
                                                sharre.activeStart = sharreActiveStart
                                                sharre.activeEnd = sharreActiveEnd
                                            }
                                            
                                            sharre.rating = subJson["currentRating"].double!
                                            
                                            self.sharesCollection.append(sharre)
                                        }
                                    }
                                    self.sharesCollectionView.reloadData()
                                } else {
                                    self.title = "No Result"
                                }
                            }
                        case .failure(_):
                            print("Search for Sharre API failed")
                            break
                        }
                    }
                }
                break
            case .failure(_):
                print("Get User Combined Rating API failed")
                break
            }
        }
        
    }
    
    // Set up Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sharesCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sharesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "sharesInfoCell", for: indexPath as IndexPath) as! SharesInfoCollectionViewCell
        sharesCell.sharesTitle.text = sharesCollection[indexPath.item].name
        
        if sharesCollection[indexPath.item].photos.count != 0 {
            ImageDownloader().imageFromServerURL(urlString: SharritURL.devPhotoURL + sharesCollection[indexPath.item].photos[0], imageView: sharesCell.sharesImage)
        }
        
        sharesCell.sharesDeposit.text = "Deposit: " + String(describing: sharesCollection[indexPath.item].deposit)
        
        if sharesCollection[indexPath.item].unit == 1 {
            sharesCell.sharesPrice.text = "Cost/Day: " + String(describing:sharesCollection[indexPath.item].price)
        } else {
            sharesCell.sharesPrice.text = "Cost/Hr: " + String(describing:sharesCollection[indexPath.item].price)
        }
        
        let rating = sharesCollection[indexPath.item].rating!
        sharesCell.sharesRating.rating = 1
        sharesCell.sharesRating.settings.totalStars = 1
        if rating != -1 {
            sharesCell.sharesRating.text = String(format: "%.2f", arguments: [rating])
        } else {
            sharesCell.sharesRating.text = "Rating Unavailable"
        }
        
        return sharesCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: sharesCollectionView.layer.frame.width/2 - 10,
                      height: sharesCollectionView.layer.frame.height/3 + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = sharesCollectionView.layer.frame.width - 10
        
        let leftInset = (sharesCollectionView.layer.frame.width - CGFloat(totalCellWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(leftInset, leftInset, leftInset, rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewSharre", sender: sharesCollection[indexPath.item].sharreId)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewSharre" {
            if let viewSharreVC = segue.destination as? ViewSharreVC {
                viewSharreVC.sharreID = sender as! Int
                
//                if collaborationList != nil {
//                    viewSharreVC.collaborationList = collaborationList
//                }
            }
        }
    }

}

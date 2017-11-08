//
//  BusinessSharesVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 27/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum ArriveFrom {
    case SharingBusiness
    case Sharror
    case Sharrie
}

class BusinessSharesVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // Pass Over Data
    var businessID: Int?
    var collaborationList: [JSON]!
    
    var sharesCollection: [Shares]! = []
    var arriveFrom = ArriveFrom.SharingBusiness
    
    var url: String!
    
    @IBOutlet weak var sharesCollectionView: UICollectionView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch arriveFrom {
        case .Sharror:
            title = "Offered Sharres"
            break
        case .Sharrie:
            title = "Requested Sharres"
            break
        case .SharingBusiness:
            title = "Business Sharres"
            url = SharritURL.devURL + "sharre/business/" + String(describing: businessID!)
            break
        }
        
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getSharesForBusiness()
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
    
    // Get Shares for Business
    func getSharesForBusiness() {
        
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
                        userRating = JSON(data)["content"].double!
                    }
                    
                    // Based on rating get business sharre and deposit given
                    Alamofire.request(self.url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                        response in
                        switch response.result {
                        case .success(_):
                            self.sharesCollection = []
                            if let data = response.result.value {
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
                            }
                            break
                        case .failure(_):
                            print("Retrieve Shares for Business API failed")
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
    
    // Go To Messages
    func goToMessages() {
        let messageSB = UIStoryboard(name: "Messages" , bundle: nil)
        let messageVC = messageSB.instantiateViewController(withIdentifier: "messages") as! MessagesVC
        let messageWithNavController = UINavigationController(rootViewController: messageVC)
        
        messageWithNavController.modalTransitionStyle = .coverVertical
        modalPresentationStyle = .fullScreen
        present(messageWithNavController, animated: true, completion:{
            if let subviewsCount = self.tabBarController?.view.subviews.count {
                if subviewsCount > 2 {
                    self.tabBarController?.view.subviews[2].removeFromSuperview()
                }
            }
        })
    }
    
    // Setup Search Bar
    func setPlaceHolder(placeholder: String) -> String {
        var text = placeholder
        if text.characters.last! != " " {
            let maxSize = CGSize(width: UIScreen.main.bounds.size.width - 130, height: 40)
            let widthText = text.boundingRect( with: maxSize, options: .usesLineFragmentOrigin, attributes:nil, context:nil).size.width
            let widthSpace = " ".boundingRect( with: maxSize, options: .usesLineFragmentOrigin, attributes:nil, context:nil).size.width
            let spaces = floor((maxSize.width - widthText) / widthSpace) - 18
            
            let newText = text + ((Array(repeating: " ", count: Int(spaces)).joined(separator: "")))
            
            if newText != text {
                return newText
            }
        }
        return placeholder;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewSharre" {
            if let viewSharreVC = segue.destination as? ViewSharreVC {
                viewSharreVC.sharreID = sender as! Int
                
                if !collaborationList.isEmpty {
                    viewSharreVC.collaborationList = collaborationList
                }
            }
        }
    }
    
}

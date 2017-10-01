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
    
    var sharesCollection: [Shares]! = []
    var arriveFrom = ArriveFrom.SharingBusiness
    
    var businessID: Int?
    
    var url: String!
    
    @IBOutlet weak var sharesCollectionView: UICollectionView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch arriveFrom {
        case .Sharror:
            // MUST TODO:
            title = "Offered Sharres"
            break
        case .Sharrie:
            // MUST TODO:
            title = "Requested Sharres"
            break
        case .SharingBusiness:
            title = "Business Sharres"
            url = SharritURL.devURL + "sharre/business/" + String(describing: businessID!)
            break
        }
        
        getSharesForBusiness()
        
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
    }
    
    // Set up Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sharesCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sharesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "sharesInfoCell", for: indexPath as IndexPath) as! SharesInfoCollectionViewCell
        sharesCell.sharesTitle.text = sharesCollection[indexPath.item].name
        // ImageDownloader().imageFromServerURL(urlString: sharesCollection[indexPath.item].logoURL, imageView: sharesCell.sharesImage) -> Cover Page
        sharesCell.sharesDeposit.text = "Deposit: " + String(describing: sharesCollection[indexPath.item].deposit)
        
        if sharesCollection[indexPath.item].unit == 1 {
            sharesCell.sharesPrice.text = "Cost/Day: " + String(describing:sharesCollection[indexPath.item].price)
        } else {
            sharesCell.sharesPrice.text = "Cost/Hr: " + String(describing:sharesCollection[indexPath.item].price)
        }
        
        sharesCell.sharesRating.rating = 4.5
        
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
        performSegue(withIdentifier: "viewSharre", sender: nil)
    }
    
    // Get Shares for Business
    func getSharesForBusiness() {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + appDelegate.user!.accessToken,
            "Accept": "application/json" // Need this?
        ]
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            switch response.result {
            case .success(_):
                self.sharesCollection = []
                if let data = response.result.value {
                    let json = JSON(data)
                    for (count, subJson) in json["content"] {
                        for (key, subInnerJSON) in subJson {
                            let sharreId = subInnerJSON["sharreId"].int!
                            let sharreName = subInnerJSON["name"].description
                            let sharreDescription = subInnerJSON["description"].description
                            let sharreType = subInnerJSON["type"].int!
                            let sharreQty = subInnerJSON["qty"].int!
                            let sharreUnit = subInnerJSON["unit"].int!
                            let sharrePrice = subInnerJSON["price"].double!
                            let sharreDeposit = subInnerJSON["deposit"].double!
                            let sharreLocation = subInnerJSON["name"].description
                            let sharreDateCreated = subInnerJSON["name"].description
                            let sharreOwnerType = subInnerJSON["ownerType"].int!
                            let sharreOwnerId = subInnerJSON["ownerId"].int!
                            let sharreIsActive = subInnerJSON["isActive"].boolValue
                            
                            let sharre = Shares(sharreId: sharreId, name: sharreName, description: sharreDescription, type: sharreType, qty: sharreQty, unit: sharreUnit, price: sharrePrice, deposit: sharreDeposit, location: sharreLocation, dateCreated: sharreDateCreated, ownerType: sharreOwnerType, ownerId: sharreOwnerId, isActive: sharreIsActive)
                            
                            let sharreActiveStart = subInnerJSON["activeStart"].description
                            let sharreActiveEnd = subInnerJSON["activeEnd"].description
                            
                            if sharreActiveStart != "00:00:00" && sharreActiveEnd != "00:00:00" {
                                sharre.activeStart = sharreActiveStart
                                sharre.activeEnd = sharreActiveEnd
                            }
                            
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
    
}

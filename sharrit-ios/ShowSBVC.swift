//
//  ShowSBVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 27/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum BusinessStatus {
    case Joined
    case Pending
}

class ShowSBVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    var businessCollection: [Business]! = [] // For Joined and Pending
    
    var businessStatus: BusinessStatus! {
        didSet {
            if businessStatus == .Joined {
                
            } else {
                
            }
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getBusinessForUser()
        
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return businessCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let businessCell = collectionView.dequeueReusableCell(withReuseIdentifier: "businessInfoCell", for: indexPath as IndexPath) as! BusinessInfoCollectionViewCell
        ImageDownloader().imageFromServerURL(urlString: "https://is41031718it02.southeastasia.cloudapp.azure.com/uploads/category/" + businessCollection[indexPath.item].logoURL, imageView: businessCell.businessImage)
        businessCell.businessTitle.text = businessCollection[indexPath.item].businessName
        
        businessCell.businessRating.rating = 4.7 // Must TODO: In Future
        
        // Get Company Creation Date and Format it
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+08")! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let currentDate = Date()
        let currentDateString = dateFormatter.string(from: currentDate)
        let todayDate = dateFormatter.date(from: currentDateString)
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        let endDate = dateFormatter2.date(from: businessCollection[indexPath.item].dateCreated)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .weekOfMonth]
        formatter.unitsStyle = .full
        businessCell.businessDate.text = formatter.string(from: endDate!, to: todayDate!)
        
        return businessCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.layer.frame.width/2 - 10,
                          height: collectionView.layer.frame.height/3 + 10)
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
        
        let totalCellWidth = collectionView.layer.frame.width/2 * 2 - 10
        
        let leftInset = (collectionView.layer.frame.width - CGFloat(totalCellWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(leftInset, leftInset, leftInset, rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewBusinessInfo", sender: businessCollection[indexPath.item])
    }
    
    func goToMessages() {
        let messageSB = UIStoryboard(name: "Messages", bundle: nil)
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
    
    // Retrieve Business based on User - Sharror
    func getBusinessForUser() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var url = ""
        
        if businessStatus == .Joined {
            url = SharritURL.devURL + "sharror/" + String(describing: appDelegate.user!.userID)
        } else {
            // Must TODO: Ronald Give Me
            //url = SharritURL.devURL + "sharror/" + String(describing: appDelegate.user!.userID)
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + appDelegate.user!.accessToken,
            "Accept": "application/json" // Need this?
        ]
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            switch response.result {
            case .success(_):
                self.businessCollection = []
                if let data = response.result.value {
                    for (count, subJson) in JSON(data)["content"] {
                        for (key, subInnerJSON) in subJson {
                            let businessId = subInnerJSON["businessId"].int!
                            let businessName = subInnerJSON["name"].description
                            let description = subInnerJSON["description"].description
                            let businessType = subInnerJSON["type"].int!
                            let logo = subInnerJSON["logo"].description
                            let banner = subInnerJSON["banner"].description
                            let comRate = subInnerJSON["comissionRate"].double!
                            let dateCreated = subInnerJSON["dateCreated"].description
                            
                            let business = Business(businessId: businessId, businessName: businessName, description: description, businessType: businessType, logoURL: logo, bannerURL: banner, commissionRate: comRate, dateCreated: dateCreated)
                            
                            let requestFormID = subInnerJSON["requestFormId"].int!
                            if requestFormID == -1 { business.requestFormID = requestFormID }
                            
                            self.businessCollection.append(business)
                        }
                    }
                    self.collectionView.reloadData()
                }
                break
            case .failure(_):
                print("Retrieve Business for User API failed")
                break
            }
        }
    }
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewBusinessInfo" {
            if let sharesInfoVC = segue.destination as? SharesInfoVC {
                sharesInfoVC.businessInfo = sender as! Business
            }
        }
    }
}

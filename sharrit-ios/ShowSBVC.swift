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

class ShowSBVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    var businessCollection: [Business]! = []
    
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
        return 7 //businessCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let businessCell = collectionView.dequeueReusableCell(withReuseIdentifier: "businessInfoCell", for: indexPath as IndexPath) as! BusinessInfoCollectionViewCell
        //ImageDownloader().imageFromServerURL(urlString: "https://is41031718it02.southeastasia.cloudapp.azure.com/uploads/category/" + allCategoriesImageStr[indexPath.item], imageView: businessCell.businessImage)
        //businessCell.businessTitle.text =
        businessCell.businessRating.rating = 4.7
        //businessCell.businessDate
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
        //performSegue(withIdentifier: "viewSharesInfo", sender: sharesCollection[indexPath.item])
    }
    
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
    
    // Retrieve Business based on User - Sharror
    func getBusinessForUser() {
        let url = SharritURL.devURL + ""
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
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
                    for (_, subJson) in JSON(data)["content"] {
                        let businessId = subJson["businessId"].int!
                        let businessName = subJson["name"].description
                        let description = subJson["description"].description
                        let businessType = subJson["type"].int!
                        let logo = subJson["logo"].description
                        let banner = subJson["banner"].description
                        let comRate = subJson["comissionRate"].double!
                        let dateCreated = subJson["dateCreated"].description
                        var business = Business(businessId: businessId, businessName: businessName, description: description, businessType: businessType, logoURL: logo, bannerURL: banner, commissionRate: comRate, dateCreated: dateCreated)
                        
                        let requestFormID = subJson["requestFormId"].int!
                        if requestFormID == -1 { business.requestFormID = requestFormID }
                        
                        self.businessCollection.append(business)
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
    
}

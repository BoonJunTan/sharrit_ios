//
//  CollaborationVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 8/11/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CollaborationVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // Pass Over Data
    var receiverID: Int!
    var receiverName: String!
    var receiverType: Int!
    var sharreTitle: String!
    var sharreID: Int!
    var sharreDescription: String!
    var sharreImageURL: String!
    var collaborationList: [JSON]!
    
    @IBOutlet weak var collaborationCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Set up all necessary component for Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collaborationList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collaborationCell", for: indexPath as IndexPath) as! CollaborationCollectionViewCell
        
        cell.dealNumber.text = "Deal " + String(describing: (indexPath.row + 1)) + " of " + String(describing: collaborationList.count)
        cell.dealTitle.text = collaborationList[indexPath.row]["title"].description
        cell.dealSubTitle.text = collaborationList[indexPath.row]["subtitle"].description
        ImageDownloader().imageFromServerURL(urlString: SharritURL.devPhotoURL + collaborationList[indexPath.row]["fileName"].description, imageView: cell.dealImage)
        
        cell.dealButton.tag = indexPath.row
        cell.dealButton.addTarget(self, action: #selector(goToDeal), for: .touchUpInside)
        cell.skipAllButton.addTarget(self, action: #selector(goToMessage), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collaborationCollectionView.layer.frame.width - 10,
                      height: collaborationCollectionView.layer.frame.height - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = collaborationCollectionView.layer.frame.width - 10
        let totalCellHeight = collaborationCollectionView.layer.frame.height - 10
        
        let leftInset = (collaborationCollectionView.layer.frame.width - CGFloat(totalCellWidth)) / 2
        let rightInset = leftInset
        
        let topInset = (collaborationCollectionView.layer.frame.height - CGFloat(totalCellHeight)) / 2
        let btnInset = topInset
        
        return UIEdgeInsetsMake(topInset, leftInset, btnInset, rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    
    func goToDeal(sender: UIButton?) {
        // MUST TODO: Waiting for Ronald to give businessID in collaborationList
        // Redirect To biz/{biz_id}
        //let url = SharritURL.devURL + "business/all/" + String(describing: collaborationList[sender!.tag]["bizId"].int!)
        let url = SharritURL.devURL + "business/all/1"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    let businessId = JSON(data)["content"]["business"]["businessId"].int!
                    let businessName = JSON(data)["content"]["business"]["name"].description
                    let description = JSON(data)["content"]["business"]["description"].description
                    let businessType = JSON(data)["content"]["business"]["type"].int!
                    let logo = JSON(data)["content"]["business"]["logo"]["fileName"].description //Logo is null
                    let banner = JSON(data)["content"]["business"]["banner"]["fileName"].description //banner is null
                    let comRate = JSON(data)["content"]["business"]["comissionRate"].double!
                    let dateCreated = JSON(data)["content"]["business"]["dateCreated"].description
                    let business = Business(businessId: businessId, businessName: businessName, description: description, businessType: businessType, logoURL: logo, bannerURL: banner, commissionRate: comRate, dateCreated: dateCreated)
                    
                    business.requestFormID = JSON(data)["content"]["business"]["requestFormId"].int!
                    business.rating = JSON(data)["content"]["currentRating"].double!
                    
                    for (_, subJson) in JSON(data)["content"]["sharres"] {
                        for (_, rating) in subJson["allRating"] {
                            business.ratingList?.append(rating)
                        }
                    }
                    
                    business.categoryID = JSON(data)["content"]["business"]["category"]["categoryId"].int!
                    business.categoryName = JSON(data)["content"]["business"]["category"]["categoryName"].description
                    
                    self.performSegue(withIdentifier: "viewShareInfo", sender: business)
                }
            case .failure(_):
                print("Get SB Info API failed")
                break
            }
        }
    }
    
    func goToMessage(sender: UIButton?) {
        let messageSB = UIStoryboard(name: "Messages" , bundle: nil)
        let conversationVC = messageSB.instantiateViewController(withIdentifier: "conversation") as! ConversationVC
        let messageWithNavController = UINavigationController(rootViewController: conversationVC)
        
        conversationVC.comingFrom = .Sharre
        conversationVC.senderDisplayName = self.receiverName
        conversationVC.receiverID = self.receiverID
        conversationVC.receiverType = self.receiverType
        let chat = Conversation(conversationPartner: self.receiverName, subjectTitle: self.sharreTitle)
        chat.sharreID = self.sharreID
        chat.sharreTitle = self.sharreTitle
        chat.sharreImageURL = self.sharreImageURL
        chat.sharreDescription = self.sharreDescription
        conversationVC.chat = chat
        
        messageWithNavController.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .fullScreen
        self.present(messageWithNavController, animated: true, completion:{
            if let subviewsCount = self.tabBarController?.view.subviews.count {
                if subviewsCount > 2 {
                    self.tabBarController?.view.subviews[2].removeFromSuperview()
                }
            }
        })
    }
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewShareInfo" {
            if let sharesInfoVC = segue.destination as? SharesInfoVC {
                sharesInfoVC.businessInfo = sender as! Business
                sharesInfoVC.categoryID = (sender as! Business).categoryID
                sharesInfoVC.categoryName = (sender as! Business).categoryName
            }
        }
    }

}

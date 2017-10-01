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
    
    var searchBar:UISearchBar!
    var sharesCollection: [Shares]! = []
    var arriveFrom = ArriveFrom.SharingBusiness
    
    @IBOutlet weak var sharesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSharesForBusiness()
        
        var arrivingFrom:String!
        
        switch arriveFrom {
        case .Sharror:
            arrivingFrom = "Offered Sharres"
            break
        case .Sharrie:
            arrivingFrom = "Requested Sharres"
            break
        case .SharingBusiness:
            arrivingFrom = "Business Sharres"
            break
        }
        
        searchBar = UISearchBar()
        searchBar.placeholder = setPlaceHolder(placeholder: "Search " + arrivingFrom);
        self.navigationItem.titleView = searchBar
        
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
    }
    
    // Set up Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7 //sharesCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sharesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "sharesInfoCell", for: indexPath as IndexPath) as! SharesInfoCollectionViewCell
        //sharesCell.sharesTitle.text = sharesCollection[indexPath.item].businessName
        
        // Image
        //ImageDownloader().imageFromServerURL(urlString: sharesCollection[indexPath.item].logoURL, imageView: sharesCell.sharesImage)
        
        return sharesCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: sharesCollectionView.layer.frame.width/2 - 10,
                      height: sharesCollectionView.layer.frame.height/3 + 10)
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
        
        let totalCellWidth = sharesCollectionView.layer.frame.width/2 * 2 - 10
        
        let leftInset = (sharesCollectionView.layer.frame.width - CGFloat(totalCellWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(leftInset, leftInset, leftInset, rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewSharre", sender: nil)
    }
    
    // Get Shares for Business
    func getSharesForBusiness() {
        // MUST TODO: Waiting for Ronald
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
                self.sharesCollection = []
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
                        
                        //self.sharesCollection.append(business)
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

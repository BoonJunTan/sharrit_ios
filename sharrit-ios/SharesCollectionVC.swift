//
//  SharesCollectionVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 20/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum CompanyList {
    case All
    case FirstParty
    case ThirdParty
}

class SharesCollectionVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var allCategories: [String]!
    var allCategoriesImageStr: [String]!
    var currentCategory: String!
    var currentCategoryID: Int!
    
    var sharesCollection: [Business]! = []
    
    var viewCompanyBy: CompanyList = .All
    
    // Future Implementation - Location, View & Filter
    // View
    @IBOutlet weak var viewTabView: UIView!
    @IBOutlet weak var viewDropDown: UIView!
    @IBOutlet weak var viewChoiceLabel: UILabel!
    
    // Filter
    @IBOutlet weak var filterTabView: UIView!
    @IBOutlet weak var filterDropDown: UIView!
    @IBOutlet weak var filterChoiceLabel: UILabel!
    
    @IBOutlet weak var tabCollectionView: UICollectionView!
    @IBOutlet weak var sharesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = currentCategory
        
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
        
        viewDropDown.isHidden = true
        let viewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewBtnTapped(tapGestureRecognizer:)))
        viewTabView.addGestureRecognizer(viewTapGestureRecognizer)
        
        filterDropDown.isHidden = true
        let filterTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(filterBtnTapped(tapGestureRecognizer:)))
        filterTabView.addGestureRecognizer(filterTapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getSharesForCategory()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tabCollectionView {
            return allCategories.count
        } else {
            return sharesCollection.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tabCollectionView {
            let tabCell = collectionView.dequeueReusableCell(withReuseIdentifier: "tabCell", for: indexPath as IndexPath) as! TabCollectionViewCell
            ImageDownloader().imageFromServerURL(urlString: "https://is41031718it02.southeastasia.cloudapp.azure.com/uploads/category/" + allCategoriesImageStr[indexPath.item], imageView: tabCell.tabImage)
            tabCell.tabLabel.text = allCategories[indexPath.item]
            return tabCell
        } else {
            let sharesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "sharesCell", for: indexPath as IndexPath) as! SharesCollectionViewCell
            sharesCell.sharesTitle.text = sharesCollection[indexPath.item].businessName
            
            // Get Company Creation Date and Format it
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+08")! as TimeZone
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let currentDate = Date()
            let currentDateString = dateFormatter.string(from: currentDate)
            let todayDate = dateFormatter.date(from: currentDateString)
            
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            let endDate = dateFormatter2.date(from: sharesCollection[indexPath.item].dateCreated)
            
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .weekOfMonth]
            formatter.unitsStyle = .full
            sharesCell.sharesCreatedDate.text = formatter.string(from: endDate!, to: todayDate!)
            
            ImageDownloader().imageFromServerURL(urlString: SharritURL.devPhotoURL + sharesCollection[indexPath.item].logoURL, imageView: sharesCell.sharesImage)
            
            let rating = sharesCollection[indexPath.item].rating
            
            sharesCell.sharreRating.rating = 1
            sharesCell.sharreRating.settings.totalStars = 1
            if rating != -1 {
                sharesCell.sharreRating.text = String(format: "%.2f", arguments: [sharesCollection[indexPath.item].rating])
            } else {
                sharesCell.sharreRating.text = "No Ratings Yet"
            }
            
            return sharesCell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == tabCollectionView {
            return CGSize(width: tabCollectionView.layer.frame.width/4,
                          height: tabCollectionView.layer.frame.height)
        } else {
            return CGSize(width: sharesCollectionView.layer.frame.width/2 - 10,
                          height: sharesCollectionView.layer.frame.height/2 + 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == tabCollectionView {
            return 0
        } else {
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == tabCollectionView {
            return 0
        } else {
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = sharesCollectionView.layer.frame.width/2 * 2 - 10
        
        let leftInset = (sharesCollectionView.layer.frame.width - CGFloat(totalCellWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(leftInset, leftInset, leftInset, rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == tabCollectionView {
            getSharesForCategory()
        } else {
            performSegue(withIdentifier: "viewSharesInfo", sender: sharesCollection[indexPath.item])
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
    
    // View by functions
    func viewBtnTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        viewDropDown.isHidden = !viewDropDown.isHidden
    }
    
    @IBAction func viewChoiceBtnTapped(_ sender: UIButton) {
        viewChoiceLabel.text = sender.titleLabel?.text
        if sender.titleLabel!.text!.contains("All") {
            viewCompanyBy = .All
        } else if sender.titleLabel!.text!.contains("1st") {
            viewCompanyBy = .FirstParty
        } else {
            viewCompanyBy = .ThirdParty
        }
        viewDropDown.isHidden = true
        getSharesForCategory()
    }
    
    // Filter by functions
    func filterBtnTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        filterDropDown.isHidden = !filterDropDown.isHidden
    }
    
    @IBAction func filterChoiceBtnTapped(_ sender: UIButton) {
        filterChoiceLabel.text = sender.titleLabel?.text
        filterDropDown.isHidden = true
    }
    
    // Retrieve Business based on category
    func getSharesForCategory() {
        var url: String!
        
        if viewCompanyBy == .All {
            url = SharritURL.devURL + "business/category/" + String(describing: currentCategoryID!)
        } else if viewCompanyBy == .FirstParty {
            url = SharritURL.devURL + "business/ios/first/" + String(describing: currentCategoryID!)
        } else {
            url = SharritURL.devURL + "business/ios/third/" + String(describing: currentCategoryID!)
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                self.sharesCollection = []
                if let data = response.result.value {
                    for (_, subJson) in JSON(data)["content"] {
                        let businessId = subJson["business"]["businessId"].int!
                        let businessName = subJson["business"]["name"].description
                        let description = subJson["business"]["description"].description
                        let businessType = subJson["business"]["type"].int!
                        let logo = subJson["business"]["logo"]["fileName"].description
                        let banner = subJson["business"]["banner"]["fileName"].description
                        let comRate = subJson["business"]["comissionRate"].double!
                        let dateCreated = subJson["business"]["dateCreated"].description
                        let business = Business(businessId: businessId, businessName: businessName, description: description, businessType: businessType, logoURL: logo, bannerURL: banner, commissionRate: comRate, dateCreated: dateCreated)
                        
                        business.requestFormID = subJson["business"]["requestFormId"].int!
                        business.rating = subJson["rating"]["currentRating"].double!
                        business.ratingList = subJson["rating"]["allRating"].array!
                        
                        self.sharesCollection.append(business)
                    }
                    self.sharesCollectionView.reloadData()
                }
                break
            case .failure(_):
                print("Retrieve categories API failed")
                break
            }
        }
    }
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewSharesInfo" {
            if let sharesInfoVC = segue.destination as? SharesInfoVC {
                sharesInfoVC.businessInfo = sender as! Business
                sharesInfoVC.categoryID = currentCategoryID
                sharesInfoVC.categoryName = currentCategory
            }
        }
    }
}

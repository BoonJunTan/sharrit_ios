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

class SharesCollectionVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var allCategories: [String]!
    var allCategoriesImageStr: [String]!
    var currentCategory: String!
    var currentCategoryID: Int!
    var searchBar:UISearchBar!
    
    var sharesCollection: [Business]! = []
    
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
        
        getSharesForCategory()
        
        searchBar = UISearchBar()
        searchBar.placeholder = setPlaceHolder(placeholder: "Search " + currentCategory);
        self.navigationItem.titleView = searchBar
        
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
            currentCategoryID = (indexPath.item + 1)
            searchBar.placeholder = setPlaceHolder(placeholder: "Search " + allCategories[indexPath.item]);
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
    
    // Setup Search Bar
    func setPlaceHolder(placeholder: String) -> String {
        var text = placeholder
        if text.characters.last! != " " {
            let maxSize = CGSize(width: UIScreen.main.bounds.size.width, height: 40)
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
    
    // View by functions
    func viewBtnTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        viewDropDown.isHidden = !viewDropDown.isHidden
    }
    
    @IBAction func viewChoiceBtnTapped(_ sender: UIButton) {
        viewChoiceLabel.text = sender.titleLabel?.text
        viewDropDown.isHidden = true
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
        let url = SharritURL.devURL + "business/category/" + String(describing: currentCategoryID!)
        
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
                        let logo = subJson["logo"]["fileName"].description
                        let banner = subJson["banner"]["fileName"].description
                        let comRate = subJson["comissionRate"].double!
                        let dateCreated = subJson["dateCreated"].description
                        let business = Business(businessId: businessId, businessName: businessName, description: description, businessType: businessType, logoURL: logo, bannerURL: banner, commissionRate: comRate, dateCreated: dateCreated)
                        
                        let requestFormID = subJson["requestFormId"].int!
                        if requestFormID == -1 { business.requestFormID = requestFormID }
                        
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

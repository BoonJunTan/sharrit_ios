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
    var currentCategory: String!
    var currentCategoryID: Int!
    var searchBar:UISearchBar!
    
    var sharesCollection: [Business]! = []
    
    // Future Implementation - Location, Category & Filter
    @IBOutlet weak var categoryTabView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryDropDown: UIView!
    @IBOutlet weak var categoryStackView: UIStackView!
    
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
        
        categoryLabel.text = currentCategory
        for var i in 0..<allCategories.count {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
            button.setTitle(allCategories[i], for: .normal)
            button.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
            button.addTarget(self, action: #selector(categoryChoiceBtnTapped), for: .touchUpInside)
            categoryStackView.addArrangedSubview(button)
        }
        
        categoryDropDown.isHidden = true
        let categoryTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(categoryBtnTapped(tapGestureRecognizer:)))
        categoryTabView.addGestureRecognizer(categoryTapGestureRecognizer)
        
        filterDropDown.isHidden = true
        let filterTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(filterBtnTapped(tapGestureRecognizer:)))
        filterTabView.addGestureRecognizer(filterTapGestureRecognizer)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tabCollectionView {
            return 7
        } else {
            return sharesCollection.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tabCollectionView {
            
            let tabCell = collectionView.dequeueReusableCell(withReuseIdentifier: "tabCell", for: indexPath as IndexPath) as! TabCollectionViewCell
            tabCell.tabImage.image = #imageLiteral(resourceName: "category1")
            tabCell.tabLabel.text = "This is for tab label"
            return tabCell
            
        } else {
            let sharesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "sharesCell", for: indexPath as IndexPath) as! SharesCollectionViewCell
            //sharesCell.sharesTitle =
            //sharesCell.sharesCreatedDate =
            //sharesCell.sharesOwnerImage =
            sharesCell.sharesOwnerName.text = sharesCollection[indexPath.item].businessName
            sharesCell.sharesImage.image = #imageLiteral(resourceName: "power_bank")
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
            
        } else {
            performSegue(withIdentifier: "viewSharesInfo", sender: sharesCollection[indexPath.item])
        }
        //let selectedCategory = categoryLabel[indexPath.item]
        //performSegue(withIdentifier: "viewSharesCollection", sender: selectedCategory)
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
    
    func categoryBtnTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        categoryDropDown.isHidden = !categoryDropDown.isHidden
    }
    
    func categoryChoiceBtnTapped(_ sender: UIButton) {
        categoryLabel.text = sender.titleLabel?.text
        categoryDropDown.isHidden = true
    }
    
    func filterBtnTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        filterDropDown.isHidden = !filterDropDown.isHidden
    }
    
    @IBAction func filterChoiceBtnTapped(_ sender: UIButton) {
        filterChoiceLabel.text = sender.titleLabel?.text
        filterDropDown.isHidden = true
    }
    
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
                if let data = response.result.value {
                    for (_, subJson) in JSON(data)["content"] {
                        let businessId = subJson["businessId"].int!
                        let businessName = subJson["name"].description
                        let description = subJson["description"].description
                        let dateCreated = subJson["dateCreated"].description
                        self.sharesCollection.append(Business(businessId: subJson["businessId"].int!, businessName: businessName, description: description, dateCreated: dateCreated))
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewSharesInfo" {
            if let sharesInfoVC = segue.destination as? SharesInfoVC {
                sharesInfoVC.businessInfo = sender as! Business
            }
        }
    }
}

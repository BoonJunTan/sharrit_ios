//
//  Home.swift
//  sharrit-ios
//
//  Created by Boon Jun on 12/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import ImageSlideshow

class HomeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var searchBar:UISearchBar!
    @IBOutlet weak var carouselView: ImageSlideshow!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    var categoryImage = [#imageLiteral(resourceName: "category1"), #imageLiteral(resourceName: "category2"), #imageLiteral(resourceName: "category3"), #imageLiteral(resourceName: "category4"), #imageLiteral(resourceName: "category5"), #imageLiteral(resourceName: "category6"), #imageLiteral(resourceName: "category6"), #imageLiteral(resourceName: "category6"), #imageLiteral(resourceName: "category6"), #imageLiteral(resourceName: "category6"), #imageLiteral(resourceName: "category6"), #imageLiteral(resourceName: "category6"), #imageLiteral(resourceName: "category6"), #imageLiteral(resourceName: "category6"), #imageLiteral(resourceName: "category6"), #imageLiteral(resourceName: "category6"), #imageLiteral(resourceName: "category6"), #imageLiteral(resourceName: "category6"), #imageLiteral(resourceName: "category6"), #imageLiteral(resourceName: "category6")]
    //var categoryLabel = ["HOME APPLIANCES", "SPORTS EQUIPMENT", "WOMEN’S FASHION", "MEN’S FASHION", "TRAVEL ACCESSORIES", "TRANSPORT"]
    var categoryLabel = ["Accessories", "Video, DVD, & Blu-ray", "Travel Accessories", "Transport", "Sports & Outdoors", "Services", "Pet Accessories", "Mobile & gadgets", "Men's Fashion", "Home Appliances", "Health & Personal Care", "Games & Hobbies", "Food & Beverages", "Design & Crafts", "Computers and Peripherals", "Books", "Bags", "Automotive", "Watches", "Women's Fashion"]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        checkIfUserLoggedIn()
        
        searchBar = UISearchBar()
        searchBar.placeholder = setPlaceHolder(placeholder: "Search");
        self.navigationItem.titleView = searchBar
        
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
        
        carouselView.setImageInputs([ImageSource(image: #imageLiteral(resourceName: "carousel1")), ImageSource(image: #imageLiteral(resourceName: "carousel2")), ImageSource(image: #imageLiteral(resourceName: "carousel3"))])
        carouselView.contentScaleMode = .scaleToFill
        carouselView.slideshowInterval = 3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = NavBarUI().getNavBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath as IndexPath) as! CategoryCollectionViewCell
        
        cell.categoryImage.image = categoryImage[indexPath.item]
        cell.categoryLabel.text = categoryLabel[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: categoryCollectionView.layer.frame.width/2,
                      height: categoryCollectionView.layer.frame.height/3)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    func checkIfUserLoggedIn() {
        // Need to call UserDefaults.standard.set(userInfoDict, forKey: "userInfo") instead
        if let userInfo = UserDefaults.standard.object(forKey: "userInfo") as? [String: Any] {
            let userAccount = User(userID: Int((userInfo["userId"] as? String)!)!, firstName: userInfo["firstName"] as! String, lastName: userInfo["lastName"] as! String, password: userInfo["password"] as! String, mobile: Int((userInfo["mobile"] as? String)!)!, accessToken: userInfo["accessToken"] as! String, createDate: userInfo["dateCreated"] as! String)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.user = userAccount
        } else {
            let mainStoryboard = UIStoryboard(name: "LoginAndSignUp" , bundle: nil)
            let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "Login") as! LoginVC
            loginVC.modalTransitionStyle = .crossDissolve
            modalPresentationStyle = .fullScreen
            present(loginVC, animated: true, completion:{
                if let subviewsCount = self.tabBarController?.view.subviews.count {
                    if subviewsCount > 2 {
                        self.tabBarController?.view.subviews[2].removeFromSuperview()
                    }
                }
            })
        }
    }
    
    func setPlaceHolder(placeholder: String) -> String {
        var text = placeholder
        if text.characters.last! != " " {
            
            let maxSize = CGSize(width: UIScreen.main.bounds.size.width - 60, height: 40)
            let widthText = text.boundingRect( with: maxSize, options: .usesLineFragmentOrigin, attributes:nil, context:nil).size.width
            let widthSpace = " ".boundingRect( with: maxSize, options: .usesLineFragmentOrigin, attributes:nil, context:nil).size.width
            let spaces = floor((maxSize.width - widthText) / widthSpace) - 26
            
            let newText = text + ((Array(repeating: " ", count: Int(spaces)).joined(separator: "")))
            
            if newText != text {
                return newText
            }
            
        }
        
        return placeholder;
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
  
}

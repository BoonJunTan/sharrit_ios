//
//  Home.swift
//  sharrit-ios
//
//  Created by Boon Jun on 12/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import ImageSlideshow
import Alamofire
import SwiftyJSON

class HomeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    var searchBar:UISearchBar!
    @IBOutlet weak var carouselView: ImageSlideshow!
    var photoArraySource = [ImageSource]()
    var photoList = [String]()
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    var categoryImage: [String] = []
    var categoryImageData: [UIImage] = []
    var categoryLabel:[String] = []
    var categoryID: [Int] = []
    
    // For notification
    var notificationTimerRunning = false
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        searchBar = UISearchBar()
        searchBar.placeholder = setPlaceHolder(placeholder: "Search Sharrit");
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkIfUserLoggedIn()
        
        getBannerForCarousel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Setup Search Bar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: "showSearchPage", sender: searchBar.text!)
    }
    
    // Get Banner
    func getBannerForCarousel() {
        let url = SharritURL.devURL + "msbanner/active"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    var json = JSON(data)
                    self.photoList = []
                    
                    for (_, photoDetail) in json["content"] {
                        self.photoList.append(photoDetail["fileName"].description)
                    }
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.bannerClick))
                    self.carouselView.addGestureRecognizer(tap)
                    
                    self.getAllPhoto(photoFiles: self.photoList, completion: { photoArray in
                        self.carouselView.setImageInputs(Array(photoArray.prefix(photoArray.count)))
                        self.carouselView.contentScaleMode = .scaleToFill
                        self.carouselView.circular = false
                        self.carouselView.slideshowInterval = 5
                    })
                }
                break
            case .failure(_):
                print("Retrieve categories API failed")
                break
            }
        }
    }
    
    // Get All Banner Photo From JSON
    func getAllPhoto(photoFiles: [String], completion: @escaping ([ImageSource]) -> ()) {
        photoArraySource = [ImageSource]()
        photoList = []
        
        let myGroup = DispatchGroup()
        
        for photo in photoFiles {
            myGroup.enter()
            ImageDownloader().imageFromServerURL(urlString: SharritURL.devPhotoURL +  photo, completion: { (image) in
                DispatchQueue.main.async(execute: {
                    self.photoArraySource.append(ImageSource(image: ImageResize().resizeImageWith(image: image, newWidth: self.carouselView.layer.frame.width)))
                    self.photoList.append(photo)
                })
                myGroup.leave()
            })
        }
        
        myGroup.notify(queue: .main) {
            completion(self.photoArraySource)
        }
    }
    
    func bannerClick(sender: UITapGestureRecognizer? = nil) {
        let url = SharritURL.devURL + "msbanner/tracking/mobile/" + photoList[carouselView.currentPage] + "/" + String(describing: appDelegate.user!.userID)
        
        print(photoList[carouselView.currentPage])
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    if JSON(data)["content"]["bizId"].int != nil {
                        let getBusinessurl = SharritURL.devURL + "business/all/ios/" + String(describing: JSON(data)["content"]["bizId"].int!)
                        
                        Alamofire.request(getBusinessurl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                            response in
                            switch response.result {
                            case .success(_):
                                if let data = response.result.value {
                                    let businessId = JSON(data)["content"]["business"]["businessId"].int!
                                    let businessName = JSON(data)["content"]["business"]["name"].description
                                    let description = JSON(data)["content"]["business"]["description"].description
                                    let businessType = JSON(data)["content"]["business"]["type"].int!
                                    let logo = JSON(data)["content"]["business"]["logo"]["fileName"].description
                                    let banner = JSON(data)["content"]["business"]["banner"]["fileName"].description
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
                                    
                                    if (!JSON(data)["content"]["collabAssets"].isEmpty) {
                                        business.collaborationList = JSON(data)["content"]["collabAssets"].array!
                                    }
                                    
                                    self.performSegue(withIdentifier: "showBusiness", sender: business)
                                }
                                break
                            case .failure(_):
                                print("Get SB Info API failed")
                                break
                            }
                        }
                    }
                }
                break
            case .failure(_):
                print("Retrieve Business ID for MSBanner Click API failed")
                break
            }
        }
    }
    
    // Get All Category Details
    func getCategoryDetails() {
        let url = SharritURL.devURL + "category/"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                self.categoryLabel = []
                self.categoryID = []
                if let data = response.result.value {
                    for (_, subJson) in JSON(data) {
                        self.categoryImage.append(subJson["photo"]["fileName"].description)
                        self.categoryLabel.append(subJson["categoryName"].description)
                        self.categoryID.append(subJson["categoryId"].int!)
                    }
                    self.categoryCollectionView.reloadData()
                }
                break
            case .failure(_):
                print("Retrieve categories API failed")
                break
            }
        }
    }
    
    // Set up all necessary component for Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryLabel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath as IndexPath) as! CategoryCollectionViewCell
        
        ImageDownloader().imageFromServerURL(urlString: ("https://is41031718it02.southeastasia.cloudapp.azure.com/uploads/category/" + categoryImage[indexPath.item]), imageView: cell.categoryImage)
        cell.categoryLabel.text = categoryLabel[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: categoryCollectionView.layer.frame.width/2 - 5,
                      height: categoryCollectionView.layer.frame.height/3 - 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = categoryCollectionView.layer.frame.width/2 * 2 - 5
        let totalCellHeight = categoryCollectionView.layer.frame.height/3 * 3 - 5
        
        let leftInset = (categoryCollectionView.layer.frame.width - CGFloat(totalCellWidth)) / 2
        let rightInset = leftInset
        
        let topInset = (categoryCollectionView.layer.frame.height - CGFloat(totalCellHeight)) / 2
        let btnInset = topInset
        
        return UIEdgeInsetsMake(topInset, leftInset, btnInset, rightInset)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedCategory = [String : Any]()
        selectedCategory["categoryName"] = categoryLabel[indexPath.item]
        selectedCategory["categoryID"] = categoryID[indexPath.item]
        performSegue(withIdentifier: "viewSharesCollection", sender: selectedCategory)
    }
    
    // Check if User is Logged in or not
    func checkIfUserLoggedIn() {
        if let userInfo = UserDefaults.standard.object(forKey: "userInfo") as? [String: Any] {
            let userAccount = User(userID: Int((userInfo["userId"] as? String)!)!, firstName: userInfo["firstName"] as! String, lastName: userInfo["lastName"] as! String, password: userInfo["password"] as! String, mobile: (userInfo["mobile"] as! String), profilePhoto: userInfo["imageSrc"] as! String, accessToken: userInfo["accessToken"] as! String, createDate: userInfo["dateCreated"] as! String, joinedSBList: userInfo["bizList"] as! [Int], pendingSBList: userInfo["pendingList"] as! [Int])
            
            if let address = userInfo["address"] as? String {
                userAccount.address = address
            }
            
            appDelegate.user = userAccount
            
            grabLatestNotificationCount()
            
            // Update Notification Badge in background thread
            if !notificationTimerRunning {
                appDelegate.timerTest = Timer.scheduledTimer(timeInterval: 5,
                                                             target: self,
                                                             selector: #selector(grabLatestNotificationCount),
                                                             userInfo: nil,
                                                             repeats: true)
                notificationTimerRunning = true
            }
            
            getCategoryDetails()
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
    
    // Notification
    func grabLatestNotificationCount() {
        let url = SharritURL.devURL + "notification/user/count/" + String(describing: appDelegate.user!.userID)
        
        var newNotificationNumber = 0
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    newNotificationNumber = data as! Int
                    if let tabController = self.appDelegate.window?.rootViewController as? UITabBarController {
                        let tabItem = tabController.tabBar.items![3]
                        newNotificationNumber == 0 ? (tabItem.badgeValue = nil) : (tabItem.badgeValue = String(describing: newNotificationNumber))
                    }
                }
                break
            case .failure(_):
                print("Get Notification count failed!")
                break
            }
        }
    }
    
    // Setup Search Bar
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
    
    // Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewSharesCollection" {
            if let sharesCollectionVC = segue.destination as? SharesCollectionVC {
                if let category = sender as? [String : Any] {
                    sharesCollectionVC.currentCategory = category["categoryName"] as! String
                    sharesCollectionVC.allCategories = categoryLabel
                    sharesCollectionVC.allCategoriesImageStr = categoryImage
                    sharesCollectionVC.currentCategoryID = category["categoryID"] as! Int
                }
            }
        } else if segue.identifier == "showSearchPage" {
            if let searchSharreVC = segue.destination as? SearchSharreVC {
                searchSharreVC.searchText = sender as? String
            }
        } else if segue.identifier == "showBusiness" {
            if let sharesInfoVC = segue.destination as? SharesInfoVC {
                sharesInfoVC.businessInfo = sender as! Business
                sharesInfoVC.categoryID = (sender as! Business).categoryID
                sharesInfoVC.categoryName = (sender as! Business).categoryName
            }
        }
    }
  
}

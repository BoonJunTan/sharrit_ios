//
//  ViewSharreVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 27/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ImageSlideshow

class ViewSharreVC: UIViewController {
    
    // Pass Over Data
    var sharreID: Int!
    
    @IBOutlet weak var sharreImages: ImageSlideshow!
    @IBOutlet weak var sharreTitle: UILabel!
    @IBOutlet weak var sharreDate: UILabel!
    @IBOutlet weak var sharreOwner: UILabel!
    @IBOutlet weak var sharreStatus: UILabel!
    @IBOutlet weak var sharreDeposit: UILabel!
    @IBOutlet weak var sharreCharging: UILabel!
    @IBOutlet weak var sharreType: UILabel!
    @IBOutlet weak var sharreQuantity: UILabel!
    @IBOutlet weak var sharreCategory: UILabel!
    @IBOutlet weak var sharreLocation: UILabel!
    @IBOutlet weak var sharreDescription: UITextView!
    @IBOutlet weak var sharreStartTime: UILabel!
    @IBOutlet weak var sharreEndTime: UILabel!
    
    var photoArraySource = [ImageSource]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
        
        getSharesInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    func getSharesInfo() {
        let url = SharritURL.devURL + "sharre/" + String(describing: sharreID!)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + appDelegate.user!.accessToken,
            "Accept": "application/json" // Need this?
        ]
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    var json = JSON(data)
                    self.sharreTitle.text = json["content"]["name"].string!
                    self.sharreDate.text = FormatDate().compareDaysCreated(dateCreated: json["content"]["dateCreated"].string!) + " by "
                    self.sharreOwner.text = json["content"]["ownerName"].string!
                    
                    if let activeStatus = json["content"]["isActive"].bool {
                        activeStatus ? (self.sharreStatus.text = "Active") : (self.sharreStatus.text = "Not Active")
                    }
                    
                    self.sharreDeposit.text = "Deposit: $" + String(describing: json["content"]["deposit"].int!)
                    self.sharreCharging.text = "Pay/hr: $" + String(describing: json["content"]["price"].int!)
                    
                    self.getAllPhoto(jsonData: json["content"]["photos"], completion: { photoArray in
                        self.sharreImages.setImageInputs(Array(photoArray.prefix(4)))
                        self.sharreImages.contentScaleMode = .scaleToFill
                        self.sharreImages.circular = false
                    })
                    
                    if json["content"]["type"].int! == 0 {
                        if json["content"]["unit"].int! == 0 {
                            self.sharreType.text = "Appointment Based - 30 Minutes Interval"
                        } else {
                            self.sharreType.text = "Appointment Based - Daily"
                        }
                    } else {
                        self.sharreType.text = "Time-Usage Based"
                    }
                    
                    self.sharreStartTime.text = "Start Time: " + json["content"]["activeStart"].string!
                    self.sharreEndTime.text = "End Time: " + json["content"]["activeEnd"].string!
                    self.sharreQuantity.text = String(describing: json["content"]["qty"].int!) + " units left"
                    self.sharreCategory.text = json["content"]["categoryName"].string!
                    self.sharreLocation.text = json["content"]["location"].string!
                    self.sharreDescription.text = json["content"]["description"].string!
                }
                break
            case .failure(_):
                print("Retrieve Sharre Info API failed")
                break
            }
        }
    }
    
    func getAllPhoto(jsonData: JSON, completion: @escaping ([ImageSource]) -> ()) {
        photoArraySource = [ImageSource]()
        
        let myGroup = DispatchGroup()
        
        for (_, photoPath) in jsonData.reversed() {
            myGroup.enter()
            ImageDownloader().imageFromServerURL(urlString: SharritURL.devPhotoURL +  photoPath["fileName"].description, completion: { (image) in
                self.photoArraySource.append(ImageSource(image: ImageResize().resizeImageWith(image: image, newWidth: 200)))
                myGroup.leave()
            })
        }
        
        myGroup.notify(queue: .main) {
            completion(self.photoArraySource)
        }
    }
    
    @IBAction func sharreITBtnPressed(_ sender: SharritButton) {
        // Check Appointment or Time-usage based
        performSegue(withIdentifier: "viewAppointment", sender: nil)
        //performSegue(withIdentifier: "viewTimeUsage", sender: nil)
    }
    
}

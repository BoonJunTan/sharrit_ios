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
    
    var ownerID: Int!
    var ownerType: Int!
    
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
    
    @IBOutlet weak var chatSharreStackView: UIStackView!
    @IBOutlet weak var sharreItBtn: SharritButton!
    
    var sharreTypeData: SharresType!
    
    var sharreStatusBool: Bool!
    var photoArraySource = [ImageSource]()
    var photoArrayURLString: String!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getSharesInfo()
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
                    self.sharreDate.text = FormatDate().compareDaysCreated(dateCreated: json["content"]["dateCreated"].string!) + " ago by"
                    
                    self.ownerID = json["content"]["ownerId"].int!
                    self.ownerType = json["content"]["ownerType"].int!
                    self.sharreOwner.text = json["content"]["ownerName"].string!
                    if (self.appDelegate.user!.firstName + " " + self.appDelegate.user!.lastName) == self.sharreOwner.text {
                        self.chatSharreStackView.isHidden = true
                        let navBarBubble = UIBarButtonItem(image: ImageResize().resizeImageWith(image: #imageLiteral(resourceName: "edit"), newWidth: 20),
                                                           style: .plain ,
                                                           target: self, action: #selector(self.sharreAction))
                        
                        self.navigationItem.rightBarButtonItem = navBarBubble
                    }
                    
                    if let activeStatus = json["content"]["isActive"].bool {
                        self.sharreStatusBool = activeStatus
                        if activeStatus {
                            self.sharreStatus.text = "Active"
                        } else {
                            self.sharreItBtn.isHidden = true
                            self.sharreStatus.text = "Not Active"
                        }
                    }
                    
                    self.sharreDeposit.text = "Deposit: $" + json["content"]["depositIos"].description
                    
                    if !json["content"]["photos"].isEmpty {
                        let photoURLStringArray = json["content"]["photos"].array
                        self.photoArrayURLString = photoURLStringArray![photoURLStringArray!.count-1]["fileName"].description
                        self.getAllPhoto(jsonData: json["content"]["photos"], completion: { photoArray in
                            self.sharreImages.setImageInputs(Array(photoArray.prefix(4)))
                            self.sharreImages.contentScaleMode = .scaleToFill
                            self.sharreImages.circular = false
                        })
                    }
                    
                    if json["content"]["type"].int! == 0 {
                        if json["content"]["unit"].int! == 0 {
                            self.sharreType.text = "Appointment Based - 30 mins Interval"
                            self.sharreCharging.text = "Pay/hr: $" + String(describing: json["content"]["price"].double!)
                            self.sharreTypeData = .HrAppointment
                        } else {
                            self.sharreCharging.text = "Pay/day: $" + String(describing: json["content"]["price"].double!)
                            self.sharreType.text = "Appointment Based - Daily"
                            self.sharreTypeData = .DayAppointment
                        }
                    } else {
                        self.sharreType.text = "Time-Usage Based"
                        self.sharreTypeData = .TimeUsage
                    }
                    
                    self.sharreStartTime.text = "Start Time: " + json["content"]["activeStart"].string!
                    self.sharreEndTime.text = "End Time: " + json["content"]["activeEnd"].string!
                    self.sharreQuantity.text = String(describing: json["content"]["qty"].int!) + " units"
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
    
    // Sharre Actions
    func sharreAction() {
        let optionMenu = UIAlertController(title: nil, message: "What would you like to do?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            
        }
        
        let editAction = UIAlertAction(title: "Edit Sharre", style: .default) { action -> Void in
            self.performSegue(withIdentifier: "editSharre", sender: nil)
        }
        
        var deactivateOrNotTitle: String!
        if sharreStatusBool! {
            deactivateOrNotTitle = "Deactivate Sharre"
        } else {
            deactivateOrNotTitle = "Activate Sharre"
        }
        
        let deactivateAction = UIAlertAction(title: deactivateOrNotTitle, style: .default) { action -> Void in
            self.deactivateSharre()
        }
        
        let deleteAction = UIAlertAction(title: "Delete Sharre", style: .default) { action -> Void in
            self.deleteSharre()
        }
        
        optionMenu.addAction(editAction)
        optionMenu.addAction(deactivateAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func sharreITBtnPressed(_ sender: SharritButton) {
        if sharreTypeData == .TimeUsage {
            performSegue(withIdentifier: "viewTimeUsage", sender: nil)
        } else {
            performSegue(withIdentifier: "viewAppointment", sender: nil)
        }
    }
    
    // Deactivate Sharre
    func deactivateSharre() {
        var deactivateOrNotTitle: String!
        if sharreStatusBool! {
            deactivateOrNotTitle = "Deactivating Sharre"
        } else {
            deactivateOrNotTitle = "Activating Sharre"
        }
        let alert = UIAlertController(title: deactivateOrNotTitle, message: "Are you sure about this?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "I'm sure", style: .default, handler: { (_) in
            
            let url:String!
            if self.sharreStatusBool! {
                url = SharritURL.devURL + "sharre/status/" + String(describing: self.sharreID!) + "/false"
            } else {
                url = SharritURL.devURL + "sharre/status/" + String(describing: self.sharreID!) + "/true"
            }
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + self.appDelegate.user!.accessToken,
                "Accept": "application/json" // Need this?
            ]
            
            Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
                response in
                switch response.result {
                case .success(_):
                    self.getSharesInfo()
                    break
                case .failure(_):
                    print("Delete Sharre Info API failed")
                    break
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Delete Sharre
    func deleteSharre() {
        let alert = UIAlertController(title: "Deleting Sharre...", message: "Are you sure about this?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "I'm sure", style: .default, handler: { (_) in
            let url = SharritURL.devURL + "sharre/delete/" + String(describing: self.sharreID!) + "/true"
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + self.appDelegate.user!.accessToken,
                "Accept": "application/json" // Need this?
            ]
            
            Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
                response in
                switch response.result {
                case .success(_):
                    self.navigationController?.popViewController(animated: true)
                    break
                case .failure(_):
                    print("Delete Sharre Info API failed")
                    break
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSharre" {
            if let editSharreVC = segue.destination as? EditSharreVC {
                editSharreVC.sharreId = sharreID
            }
        } else if segue.identifier == "viewAppointment" {
            if let sharreBookingVC = segue.destination as? SharreBookingVC {
                sharreBookingVC.sharreID = sharreID
                sharreBookingVC.sharreTitle = sharreTitle.text!
                sharreBookingVC.sharreDescription = sharreDescription.text!
                sharreBookingVC.sharreImageURL = photoArrayURLString
                sharreBookingVC.appointmentType = sharreTypeData
                sharreBookingVC.sharreStartTime = sharreStartTime.text!
                sharreBookingVC.sharreEndTime = sharreEndTime.text!
                sharreBookingVC.ownerID = ownerID
                sharreBookingVC.ownerName = sharreOwner.text!
                sharreBookingVC.ownerType = ownerType
                let deposit = sharreDeposit.text!
                sharreBookingVC.sharreDeposit = deposit.replacingOccurrences(of: "Deposit: $", with: "")
            }
        } else if segue.identifier == "viewTimeUsage" {
            if let sharreTimeUsageVC = segue.destination as? SharreTimeUsageVC {
                sharreTimeUsageVC.sharreID = sharreID
                sharreTimeUsageVC.sharreTitle = sharreTitle.text!
                sharreTimeUsageVC.sharreDescription = sharreDescription.text!
                sharreTimeUsageVC.sharreImageURL = photoArrayURLString
                sharreTimeUsageVC.sharreDeposit = sharreDeposit.text!
                sharreTimeUsageVC.sharreUsageFee = sharreCharging.text!
                sharreTimeUsageVC.ownerID = ownerID
                sharreTimeUsageVC.ownerName = sharreOwner.text!
                sharreTimeUsageVC.ownerType = ownerType
                let quantity = sharreQuantity.text!
                sharreTimeUsageVC.sharreUnit = quantity.replacingOccurrences(of: " units", with: "")
            }
        }
    }
    
}

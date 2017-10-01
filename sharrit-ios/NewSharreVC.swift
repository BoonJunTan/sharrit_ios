//
//  NewSharreVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 27/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Photos

class NewSharreVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var currentSelectedCell: SharrePhotoCollectionViewCell!
    var currentSelectedCellIndex: Int!
    
    let imagePicker = UIImagePickerController()
    
    // Pass over data
    var businessName: String!
    var businessID: Int!
    var categoryName: String!
    var categoryID: Int!
    
    @IBOutlet weak var businessLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var sharreName: UITextField!
    @IBOutlet weak var sharreDeposit: UITextField!
    
    var scheduleTimeCode = 0
    @IBOutlet weak var sharreScheduleBtn: SharritButton!
    @IBOutlet weak var sharreTimeBtn: SharritButton!
    
    var unitCode = 1
    @IBOutlet weak var sharreDayBtn: SharritButton!
    @IBOutlet weak var sharreThirtyBtn: SharritButton!
    
    @IBOutlet weak var sharreStartTime: UITextField!
    @IBOutlet weak var sharreEndTime: UITextField!
    @IBOutlet weak var sharreChargingPrice: UITextField!
    @IBOutlet weak var sharreQuantity: UITextField!
    @IBOutlet weak var sharreLocation: UITextField!
    @IBOutlet weak var sharreDescription: UITextView!
    
    @IBOutlet weak var dayMinuteStackView: UIStackView!
    @IBOutlet weak var dayMinuteStackHeight: NSLayoutConstraint!
    
    @IBOutlet weak var startEndTimeStackView: UIStackView!
    @IBOutlet weak var startEndTimeStackHeight: NSLayoutConstraint!
    
    var sharreImages = [UIImage(), UIImage(), UIImage(), UIImage()]
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
        
        imagePicker.delegate = self
        
        businessLabel.text = businessName
        categoryLabel.text = categoryName
        
        sharreStartTime.keyboardType = .numberPad
        sharreEndTime.keyboardType = .numberPad
        sharreQuantity.keyboardType = .numberPad
        sharreChargingPrice.keyboardType = .numbersAndPunctuation
        sharreDeposit.keyboardType = .numbersAndPunctuation
        
        defaultChargeMethodBtnUI()
        currentBtnSelected(btn: sharreScheduleBtn)
        
        defaultChargeTypeBtnUI()
        currentBtnSelected(btn: sharreDayBtn)

        startEndTimeStackView.isHidden = true
        startEndTimeStackHeight.constant = 0
    }
    
    // Set up Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sharrePhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "sharrePhotoCell", for: indexPath as IndexPath) as! SharrePhotoCollectionViewCell
        indexPath.item == 0 ? (sharrePhotoCell.sharreLabel.isHidden = false) : (sharrePhotoCell.sharreLabel.isHidden = true)
        indexPath.item == 4 ? (sharrePhotoCell.sharreImage.image = #imageLiteral(resourceName: "reorder")) : (sharrePhotoCell.sharreImage.image = #imageLiteral(resourceName: "add"))
        sharrePhotoCell.cancelBtn.isHidden = true
        sharrePhotoCell.cancelBtn.layer.cornerRadius = sharrePhotoCell.cancelBtn.layer.frame.width / 2
        sharrePhotoCell.cancelBtn.layer.masksToBounds = true
        
        // Add Dotted Line
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = UIColor.black.cgColor
        yourViewBorder.lineDashPattern = [2, 2]
        yourViewBorder.frame = sharrePhotoCell.layer.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.path = UIBezierPath(rect: sharrePhotoCell.layer.bounds).cgPath
        sharrePhotoCell.layer.addSublayer(yourViewBorder)
        
        return sharrePhotoCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.layer.frame.width/4 - 10,
                      height: collectionView.layer.frame.height - 10)
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
        let totalCellHeight = collectionView.layer.frame.height - 10
        
        let leftInset = (collectionView.layer.frame.width - CGFloat(totalCellWidth)) / 2
        let topInset = (collectionView.layer.frame.height - CGFloat(totalCellHeight)) / 2
        
        return UIEdgeInsetsMake(topInset, leftInset, topInset, leftInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentSelectedCell = collectionView.cellForItem(at: indexPath) as! SharrePhotoCollectionViewCell
        currentSelectedCellIndex = indexPath.row
        // Call Image Picker
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
                break
            case .denied, .restricted:
                let alert = UIAlertController(title: "Error", message: "Sharrit has no access to your photo album. Please allow access in order to change your profile photo. Cheers!", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.openURL(settingsURL)
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            default:
                break
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            currentSelectedCell.sharreImage.image = pickedImage
            currentSelectedCell.sharreImage.contentMode = .scaleAspectFill
            currentSelectedCell.cancelBtn.isHidden = false
            sharreImages[currentSelectedCellIndex] = pickedImage
            self.dismiss(animated: true, completion: nil)
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
    
    func currentBtnSelected(btn: UIButton) {
        btn.backgroundColor = Colours.Blue.sharritBlue
        btn.setTitleColor(UIColor.white, for: .normal)
    }
    
    func defaultChargeMethodBtnUI() {
        sharreScheduleBtn.backgroundColor = UIColor.white
        sharreScheduleBtn.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
        sharreTimeBtn.backgroundColor = UIColor.white
        sharreTimeBtn.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
    }
    
    func defaultChargeTypeBtnUI() {
        sharreDayBtn.backgroundColor = UIColor.white
        sharreDayBtn.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
        sharreThirtyBtn.backgroundColor = UIColor.white
        sharreThirtyBtn.setTitleColor(Colours.Blue.sharritBlue, for: .normal)
    }
    
    @IBAction func scheduleBtnPressed(_ sender: SharritButton) {
        scheduleTimeCode = 0
        defaultChargeMethodBtnUI()
        currentBtnSelected(btn: sharreScheduleBtn)
        dayMinuteStackView.isHidden = false
        dayMinuteStackHeight.constant = 40
        startEndTimeStackView.isHidden = true
        startEndTimeStackHeight.constant = 0
        
        unitCode = 1
        defaultChargeTypeBtnUI()
        currentBtnSelected(btn: sharreDayBtn)
    }
    
    @IBAction func timeBtnPressed(_ sender: SharritButton) {
        scheduleTimeCode = 1
        defaultChargeMethodBtnUI()
        currentBtnSelected(btn: sharreTimeBtn)
        dayMinuteStackView.isHidden = true
        dayMinuteStackHeight.constant = 0
        startEndTimeStackView.isHidden = false
        startEndTimeStackHeight.constant = 40
    }
    
    @IBAction func dayBtnPressed(_ sender: SharritButton) {
        unitCode = 1
        defaultChargeTypeBtnUI()
        currentBtnSelected(btn: sharreDayBtn)
        startEndTimeStackView.isHidden = true
        startEndTimeStackHeight.constant = 0
    }
    
    @IBAction func thirtyBtnPressed(_ sender: SharritButton) {
        unitCode = 0
        defaultChargeTypeBtnUI()
        currentBtnSelected(btn: sharreThirtyBtn)
        startEndTimeStackView.isHidden = false
        startEndTimeStackHeight.constant = 40
    }
    
    @IBAction func createSharesBtnPressed(_ sender: SharritButton) {
        var errorDetected = false
        
        if sharreImages[0].size == CGSize(width: 0, height: 0) {
            errorDetected = true
        }
        
        if (sharreName.text?.isEmpty)! || (sharreDescription.text?.isEmpty)! ||  (sharreQuantity.text?.isEmpty)! || (sharreChargingPrice.text?.isEmpty)! || (sharreDeposit.text?.isEmpty)! || (sharreLocation.text?.isEmpty)! {
            errorDetected = true
        }
        
        if unitCode == 0 && ((sharreStartTime.text?.isEmpty)! || (sharreEndTime.text?.isEmpty)!) {
            errorDetected = true
        }
        
        if unitCode == -1 && !(sharreStartTime.text?.isEmpty)! && !(sharreEndTime.text?.isEmpty)! {
            unitCode = 0
        }
        
        if errorDetected {
            let alert = UIAlertController(title: "Error!", message: "Missing cover photo / Empty fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            var sharreData: [String: Any] = ["name": sharreName.text!, "description": sharreDescription.text!, "type": scheduleTimeCode, "qty": sharreQuantity.text!, "price": sharreChargingPrice.text!, "deposit": sharreDeposit.text!, "location": sharreLocation.text!]
            
            if unitCode != -1 {
                sharreData["unit"] = unitCode
            }
            
            let url = SharritURL.devURL + "sharre/third/" + String(describing: businessID!) + "/" + String(describing: appDelegate.user!.userID)
            
            Alamofire.request(url, method: .post, parameters: sharreData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                response in
                switch response.result {
                    
                case .success(_):
                    if let data = (response.result.value as? Dictionary<String, Any>) {
                        if let statusCode = data["status"] as? Int {
                            if statusCode == 1 {
                                if let value = response.result.value {
                                    var json = JSON(value)
                                    self.uploadImage(sharreID: String(describing: json["content"].int!))
                                }
                            }
                        }
                    }
                    break
                case .failure(_):
                    print("Create Sharre API failed")
                    break
                }
            }
        }
    }
    
    func uploadImage(sharreID: String) {
        let url = SharritURL.devURL + "sharre/upload/" + sharreID
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + appDelegate.user!.accessToken,
            "Accept": "application/json" // Need this?
        ]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            var counter = 0
            for image in self.sharreImages {
                if let imageData = UIImageJPEGRepresentation(image, 0.5) {
                    if counter == 0 {
                        multipartFormData.append(imageData, withName: "file", fileName: sharreID + "-picture-" + String(describing: counter) + ".jpg", mimeType: "image/jpeg")
                    } else {
                        multipartFormData.append(imageData, withName: "file" + String(describing: counter + 1), fileName: sharreID + "-picture-" + String(describing: counter) + ".jpg", mimeType: "image/jpeg")
                    }
                }
                counter = counter + 1
            }
        }, to: url, method: .post, headers: headers,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            if self.unitCode == 0 {
                                self.updateStartEndTime(sharreID: sharreID)
                            } else {
                                self.performSegue(withIdentifier: "createdSharre", sender: sharreID)
                            }
                        }
                    case .failure(_):
                        print("Upload Profile Photo API failed")
                    }
                    self.dismiss(animated: true, completion: nil)
        })
    }
    
    func updateStartEndTime(sharreID: String) {
        let url = SharritURL.devURL + "sharre/operatinghours/" + sharreID
        
        let sharreData: [String: Any] = ["activeStart": sharreStartTime.text! + ":00", "activeEnd": sharreEndTime.text! + ":00"]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + appDelegate.user!.accessToken,
            "Accept": "application/json" // Need this?
        ]
        
        Alamofire.request(url, method: .post, parameters: sharreData, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            switch response.result {
                
            case .success(_):
                if let data = (response.result.value as? Dictionary<String, Any>) {
                    if let statusCode = data["status"] as? Int {
                        if statusCode == 1 {
                            self.performSegue(withIdentifier: "createdSharre", sender: sharreID)
                        }
                    }
                }
                break
            case .failure(_):
                print("Create Sharre API failed")
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createdSharre" {
            if let sharresCreationVC = segue.destination as? SharresCreationVC {
                sharresCreationVC.sharreTitle = sharreName.text
                sharresCreationVC.sharreID = Int(sender as! String)
            }
        }
    }
}

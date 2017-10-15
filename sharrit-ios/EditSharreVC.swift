//
//  EditSharreVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 3/10/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Photos

class EditSharreVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var currentSelectedCell: SharrePhotoCollectionViewCell!
    var currentSelectedCellIndex: Int!
    
    let imagePicker = UIImagePickerController()
    
    // Pass over data
    var sharreId: Int!
    
    @IBOutlet weak var sharreName: UITextField!
    @IBOutlet weak var sharreDeposit: UITextField!
    
    var scheduleTimeCode: Int!
    @IBOutlet weak var sharreScheduleBtn: SharritButton!
    @IBOutlet weak var sharreTimeBtn: SharritButton!
    
    var unitCode: Int!
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
    
    var sharreImages = [UIImage]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        sharreQuantity.keyboardType = .numberPad
        sharreChargingPrice.keyboardType = .decimalPad
        sharreDeposit.keyboardType = .decimalPad
        
        sharreScheduleBtn.addTarget(self, action: #selector(scheduleBtnPressed), for: .touchUpInside)
        sharreTimeBtn.addTarget(self, action: #selector(timeBtnPressed), for: .touchUpInside)
        sharreDayBtn.addTarget(self, action: #selector(dayBtnPressed), for: .touchUpInside)
        sharreThirtyBtn.addTarget(self, action: #selector(thirtyBtnPressed), for: .touchUpInside)
        
        getShareDetails()
    }
    
    // Set up Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sharrePhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "sharrePhotoCell", for: indexPath as IndexPath) as! SharrePhotoCollectionViewCell
        
        indexPath.item == 0 ? (sharrePhotoCell.sharreLabel.isHidden = false) : (sharrePhotoCell.sharreLabel.isHidden = true)
        
        sharrePhotoCell.cancelBtn.layer.cornerRadius = sharrePhotoCell.cancelBtn.layer.frame.width / 2
        sharrePhotoCell.cancelBtn.layer.masksToBounds = true
        
        if sharreImages.indices.contains(indexPath.item) {
            sharrePhotoCell.sharreImage.image = sharreImages[indexPath.item]
            sharrePhotoCell.sharreImage.contentMode = .scaleAspectFill
            sharrePhotoCell.cancelBtn.isHidden = false
        } else {
            (sharrePhotoCell.sharreImage.image = #imageLiteral(resourceName: "add"))
            sharrePhotoCell.sharreImage.contentMode = .center
            sharrePhotoCell.cancelBtn.isHidden = true
        }
        
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
    
    func getShareDetails() {
        let url = SharritURL.devURL + "sharre/" + String(describing: sharreId!)
        
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
                    self.sharreName.text = json["content"]["name"].string!
                    
                    self.sharreDeposit.text = String(describing: json["content"]["deposit"].int!)
                    self.sharreChargingPrice.text = String(describing: json["content"]["price"].int!)
                    
                    self.getAllPhoto(jsonData: json["content"]["photos"], completion: { photoArray in
                        self.collectionView.reloadData()
                    })
                    
                    self.defaultChargeMethodBtnUI()
                    self.defaultChargeTypeBtnUI()
                    
                    self.scheduleTimeCode = json["content"]["type"].int!
                    if self.scheduleTimeCode == 0 {
                        self.currentBtnSelected(btn: self.sharreScheduleBtn)
                        
                        self.dayMinuteStackView.isHidden = false
                        self.dayMinuteStackHeight.constant = 40
                        self.unitCode = json["content"]["unit"].int!
                        if self.unitCode == 0 {
                            self.currentBtnSelected(btn: self.sharreThirtyBtn)
                            self.startEndTimeStackView.isHidden = false
                            self.startEndTimeStackHeight.constant = 40
                        } else {
                            self.currentBtnSelected(btn: self.sharreDayBtn)
                            self.startEndTimeStackView.isHidden = true
                            self.startEndTimeStackHeight.constant = 0
                        }
                    } else {
                        self.currentBtnSelected(btn: self.sharreTimeBtn)
                        
                        self.unitCode = -1
                        self.dayMinuteStackView.isHidden = true
                        self.dayMinuteStackHeight.constant = 0
                        self.startEndTimeStackView.isHidden = false
                        self.startEndTimeStackHeight.constant = 40
                    }
                    
                    self.sharreStartTime.text = json["content"]["activeStart"].string! + " "
                    self.sharreStartTime.text = self.sharreStartTime.text?.replacingOccurrences(of: ":00 ", with: "")
                    self.sharreEndTime.text = json["content"]["activeEnd"].string! + " "
                    self.sharreEndTime.text = self.sharreEndTime.text?.replacingOccurrences(of: ":00 ", with: "")
                    self.sharreQuantity.text = String(describing: json["content"]["qty"].int!)
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
    
    func getAllPhoto(jsonData: JSON, completion: @escaping () -> ()) {
        let myGroup = DispatchGroup()
        
        for (_, photoPath) in jsonData.reversed() {
            myGroup.enter()
            ImageDownloader().imageFromServerURL(urlString: SharritURL.devPhotoURL +  photoPath["fileName"].description, completion: { (image) in
                self.sharreImages.append(ImageResize().resizeImageWith(image: image, newWidth: 200))
                myGroup.leave()
            })
        }
        
        myGroup.notify(queue: .main) {
            completion()
        }
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
    
    func scheduleBtnPressed() {
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
    
    func timeBtnPressed() {
        scheduleTimeCode = 1
        defaultChargeMethodBtnUI()
        currentBtnSelected(btn: sharreTimeBtn)
        
        dayMinuteStackView.isHidden = true
        dayMinuteStackHeight.constant = 0
        
        unitCode = -1
        startEndTimeStackView.isHidden = false
        startEndTimeStackHeight.constant = 40
    }
    
    func dayBtnPressed() {
        unitCode = 1
        defaultChargeTypeBtnUI()
        currentBtnSelected(btn: sharreDayBtn)
        
        startEndTimeStackView.isHidden = true
        startEndTimeStackHeight.constant = 0
    }
    
    func thirtyBtnPressed() {
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
        
        if unitCode == -1 {
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
            
            let url = SharritURL.devURL + "sharre/" + String(describing: sharreId!)
            
            Alamofire.request(url, method: .put, parameters: sharreData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                response in
                switch response.result {
                    
                case .success(_):
                    if let data = (response.result.value as? Dictionary<String, Any>) {
                        if let statusCode = data["status"] as? Int {
                            if statusCode == 1 {
                                self.uploadImage(sharreID: String(describing: self.sharreId!))
                            }
                        }
                    }
                    break
                case .failure(_):
                    print("Update Sharre API failed")
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
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            case .failure(_):
                print("Update Sharre Photo API failed")
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
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                break
            case .failure(_):
                print("Update Sharre Start/End Time failed")
                break
            }
        }
    }
}


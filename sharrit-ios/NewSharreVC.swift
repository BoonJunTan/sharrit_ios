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
    @IBOutlet weak var sharreScheduleBtn: SharritButton!
    @IBOutlet weak var sharreTimeBtn: SharritButton!
    @IBOutlet weak var sharreDayBtn: SharritButton!
    @IBOutlet weak var sharreThirtyBtn: SharritButton!
    @IBOutlet weak var sharreChargingPrice: UITextField!
    @IBOutlet weak var sharreQuantity: UITextField!
    @IBOutlet weak var sharreDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
        
        imagePicker.delegate = self
        
        businessLabel.text = businessName
        categoryLabel.text = categoryName
        
        defaultChargeMethodBtnUI()
        currentBtnSelected(btn: sharreScheduleBtn)
        
        defaultChargeTypeBtnUI()
        currentBtnSelected(btn: sharreDayBtn)
        
        sharreDescription.toolbarPlaceholder = "Enter Sharre Description"
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
        defaultChargeMethodBtnUI()
        currentBtnSelected(btn: sharreScheduleBtn)
    }
    
    @IBAction func timeBtnPressed(_ sender: SharritButton) {
        defaultChargeMethodBtnUI()
        currentBtnSelected(btn: sharreTimeBtn)
    }
    
    @IBAction func dayBtnPressed(_ sender: SharritButton) {
        defaultChargeTypeBtnUI()
        currentBtnSelected(btn: sharreDayBtn)
    }
    
    @IBAction func thirtyBtnPressed(_ sender: SharritButton) {
        defaultChargeTypeBtnUI()
        currentBtnSelected(btn: sharreThirtyBtn)
    }
    
    @IBAction func createSharesBtnPressed(_ sender: SharritButton) {
        performSegue(withIdentifier: "createdSharre", sender: nil)
    }
    
}

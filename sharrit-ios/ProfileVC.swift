//
//  ProfileVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 12/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Cosmos
import Photos
import Alamofire
import SwiftyJSON

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let tableViewSection = ["COMMON", "SHARRIE", "SHARROR", "SETTINGS"]
    var tableViewIcons = [[#imageLiteral(resourceName: "reputation")], [#imageLiteral(resourceName: "transaction")], [#imageLiteral(resourceName: "Sharrit_Logo"), #imageLiteral(resourceName: "business"), #imageLiteral(resourceName: "business"), #imageLiteral(resourceName: "transaction")], [#imageLiteral(resourceName: "profile2"), #imageLiteral(resourceName: "help"), #imageLiteral(resourceName: "logout")]]
    var tableViewItems = [["Reputation"], ["Sharres Status OvervieW"], ["Sharres Offered", "Sharing Business (Joined)", "Sharing Business (Pending)", "Sharres Status Overview"], ["Profile Settings", "Help Centre", "Logout"]]

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileLabe: UILabel!
    @IBOutlet weak var starRating: CosmosView!
    let fakeRatingDouble = 4.7
    @IBOutlet weak var profileDate: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let navBarBubble = UIBarButtonItem(image: #imageLiteral(resourceName: "chat"),
                                           style: .plain ,
                                           target: self, action: #selector(goToMessages))
        
        self.navigationItem.rightBarButtonItem = navBarBubble
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // For Hiding away empty cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupProfile()
    }
    
    func setupProfile() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        profileLabe.text = (appDelegate.user?.firstName)! + " " + (appDelegate.user?.lastName)!
        
        starRating.rating = fakeRatingDouble
        starRating.settings.fillMode = .precise
        
        // Get user profile creation date
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+08")! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let currentDate = Date()
        let currentDateString = dateFormatter.string(from: currentDate)
        let todayDate = dateFormatter.date(from: currentDateString)
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        let endDate = dateFormatter2.date(from: (appDelegate.user?.createDate)!)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .weekOfMonth]
        formatter.unitsStyle = .full
        profileDate.text = formatter.string(from: endDate!, to: todayDate!)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageBtnTapped(tapGestureRecognizer:)))
        profileImage.isUserInteractionEnabled = true
        if appDelegate.user!.profilePhoto == "" {
            profileImage.image = #imageLiteral(resourceName: "profile2")
        } else {
            if let checkedUrl = URL(string: SharritURL.devPhotoURL + appDelegate.user!.profilePhoto) {
                downloadProfilePhoto(from: checkedUrl)
            }
        }
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        imagePicker.delegate = self
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewSection[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerHeight:CGFloat = tableViewSection[section].isEmpty ? 0.0 : 50.0
        return headerHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! ProfileTableViewCell
        cell.iconLabel.text = tableViewItems[indexPath.section][indexPath.row]
        cell.iconImage.image = tableViewIcons[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableViewItems[indexPath.section][indexPath.row] {
        case "Reputation":
            break
        case "Sharres Offered":
            break
        case "Sharres Status OvervieW", "Sharres Status Overview":
            self.performSegue(withIdentifier: "showShares", sender: tableViewItems[indexPath.section][indexPath.row])
            break
        case "Sharing Business (Joined)":
            self.performSegue(withIdentifier: "showSB", sender: "Joined")
            break
        case "Sharing Business (Pending)":
            self.performSegue(withIdentifier: "showSB", sender: "Pending")
            break
        case "Profile Settings":
            self.performSegue(withIdentifier: "editProfile", sender: self)
            break
        case "Help Centre":
            self.performSegue(withIdentifier: "showHelp", sender: self)
            break
        case "Logout":
            logoutPressed()
            break
        default:
            break
        }
        tableView.reloadData()
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
    
    func downloadProfilePhoto(from url: URL) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                self.profileImage.image = UIImage(data: data)
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func profileImageBtnTapped(tapGestureRecognizer: UITapGestureRecognizer) {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate

            let url = SharritURL.devURL + "user/upload/" + String(describing: appDelegate.user!.userID)
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + appDelegate.user!.accessToken,
                "Accept": "application/json" // Need this?
            ]
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                if let imageData = UIImageJPEGRepresentation(pickedImage, 0.5) {
                    multipartFormData.append(imageData, withName: "file", fileName: "userID" + String(describing: appDelegate.user!.userID) + ".png", mimeType: "image/png")
                }}, to: url, method: .post, headers: headers,
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            
                            upload.responseJSON { response in
                                if let value = response.result.value {
                                    var json = JSON(value)
                                    json["content"]["fileName"].string! = json["content"]["fileName"].string!.replacingOccurrences(of: "/uploads/", with: "")
                                    let newUrlString = json["content"]["fileName"].string!
                                        
                                    // Change Actual
                                    self.profileImage.image = pickedImage
                                    
                                    // Change App Delegate
                                    appDelegate.user!.profilePhoto = newUrlString
                                    
                                    // Change User Default
                                    if var userInfo = UserDefaults.standard.object(forKey: "userInfo") as? [String: Any] {
                                        userInfo["imageSrc"] = newUrlString
                                        UserDefaults.standard.set(userInfo, forKey: "userInfo")
                                        UserDefaults.standard.synchronize()
                                    }
                                }
                            }
                        case .failure(_):
                            print("Upload Profile Photo API failed")
                        }
                        self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    func logoutPressed() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.timerTest?.invalidate()
        appDelegate.timerTest = nil
        UserDefaults.standard.removeObject(forKey: "userInfo")
        
        let mainStoryboard = UIStoryboard(name: "LoginAndSignUp" , bundle: nil)
        let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "Login") as! LoginVC
        loginVC.modalTransitionStyle = .coverVertical
        modalPresentationStyle = .fullScreen
        present(loginVC, animated: true, completion:{
            if let subviewsCount = self.tabBarController?.view.subviews.count {
                if subviewsCount > 2 {
                    self.tabBarController?.view.subviews[2].removeFromSuperview()
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showShares" {
            if let showSharesVC = segue.destination as? ShowSharesInfoVC {
                showSharesVC.titleString = sender as? String
                sender as? String == "Sharres Status OvervieW" ? (showSharesVC.userRole = .Sharrie) : (showSharesVC.userRole = .Sharror)
            }
        } else if segue.identifier == "showSB" {
            if let showSBVC = segue.destination as? ShowSBVC {
                (sender as? String == "Joined") ? (showSBVC.businessStatus = .Joined) : (showSBVC.businessStatus = .Pending)
            }
        }
    }
    
}

//
//  ConversationVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 14/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Alamofire
import SwiftyJSON

enum ComingFrom {
    case Messages
    case Sharre
}

final class ConversationVC: JSQMessagesViewController {
    
    // If there is Sharre for Convo
    @IBOutlet weak var sharreInfoView: UIView!
    @IBOutlet weak var sharreTitle: UILabel!
    @IBOutlet weak var sharreDescription: UILabel!
    @IBOutlet weak var sharreImage: UIImageView!
    
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var senderAvatar:JSQMessagesAvatarImage!
    var receiverAvatar:JSQMessagesAvatarImage!
    
    // For location
    var locationManager: CLLocationManager!
    var currentLocation:CLLocation?
    var latitudeToSend: CLLocationDegrees?
    var longitudeToSend: CLLocationDegrees?
    
    // Pass Over Data
    var comingFrom: ComingFrom!
    var receiverID: Int?
    var receiverType: Int?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Setup for Conversation - Details
    var chat: Conversation? {
        didSet {
            title = chat?.conversationPartner
            senderId = (appDelegate.user!.firstName + " " + appDelegate.user!.lastName)
            senderDisplayName = (appDelegate.user!.firstName + " " + appDelegate.user!.lastName)
            
            senderAvatar = JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder: #imageLiteral(resourceName: "star"), diameter: 20)!
            receiverAvatar = JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder: #imageLiteral(resourceName: "profile2"), diameter: 20)!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Setup for Conversation - Outgoing & Incoming Bubble
        outgoingBubbleImageView = setupOutgoingBubble()
        incomingBubbleImageView = setupIncomingBubble()
        
        // Setup for Conversation - Profile
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault)
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault)
        
        collectionView?.collectionViewLayout.springinessEnabled = false
        automaticallyScrollsToMostRecentMessage = true
        
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
        
        if chat?.sharreID != nil {
            sharreTitle.text = chat!.sharreTitle!
            sharreDescription.text = chat!.sharreDescription!
            ImageDownloader().imageFromServerURL(urlString: chat!.sharreImageURL!, imageView: sharreImage)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToSharre))
            sharreInfoView.addGestureRecognizer(tapGesture)
            sharreInfoView.isHidden = false
        } else {
            sharreInfoView.isHidden = true
        }
        
        if comingFrom == .Messages {
            getMessages()
        } else {
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        finishReceivingMessage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToSharre(sender: UITapGestureRecognizer? = nil) {
        performSegue(withIdentifier: "viewSharre", sender: nil)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        
        let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .actionSheet)
        
        let locationAction = UIAlertAction(title: "Send location", style: .default) { (action) in
            self.setupLocationManager()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sheet.addAction(locationAction)
        sheet.addAction(cancelAction)
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    // MARK: Collectionview delegate and datasource methods for MessageView
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return messages[indexPath.item].senderId == (appDelegate.user!.firstName + " " + appDelegate.user!.lastName) ? outgoingBubbleImageView : incomingBubbleImageView
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        if messages[indexPath.item].senderId == (appDelegate.user!.firstName + " " + appDelegate.user!.lastName) {
            return receiverAvatar
        } else {
            return senderAvatar
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.row]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath.item == 0) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        if (indexPath.item - 1 > 0) {
            let previousMessage = messages[indexPath.item - 1]
            let message = messages[indexPath.item]
            
            if (message.date.timeIntervalSince(previousMessage.date) / 60 > 1) {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }
        
        return 0.0
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.item]
        
        if (indexPath.item == 0) {
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        if (indexPath.item - 1 > 0) {
            let previousMessage = messages[indexPath.item - 1]
            if (message.date.timeIntervalSince(previousMessage.date) / 60 > 1) {
                return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
            }
        }
        
        return nil;
    }
    
    func buildLocationItem(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> JSQLocationMediaItem {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(location, withCompletionHandler: {
            self.collectionView!.reloadData()
        })
        
        return locationItem
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory =  JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)!
        messages.append(message)
        finishSendingMessage(animated: true)
        
        if chat!.id != nil {
            let url = SharritURL.devURL + "message/" + String(describing: chat!.id!)
            
            let messageData: [String: Any] = ["body": text, "senderName": senderId]
            
            Alamofire.request(url, method: .post, parameters: messageData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                response in
                switch response.result {
                case .success(_):
                    break
                case .failure(_):
                    print("Write new message API failed")
                    break
                }
            }
        } else {
            // Create New Message first - Sharrie
            let messageData: [String: Any] = ["subject": chat!.subjectTitle!, "senderId": appDelegate.user!.userID, "senderType": 0, "receiverType": receiverType!, "receiverId": receiverID!, "senderName": appDelegate.user!.firstName + " " + appDelegate.user!.lastName, "sharreId": chat!.sharreID!, "body" :text]
            
            let url = SharritURL.devURL + "conversation"
            
            Alamofire.request(url, method: .post, parameters: messageData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                response in
                switch response.result {
                case .success(_):
                    if let data = response.result.value {
                        // Retrieve chat ID
                        // Retrieve message based on chat ID
                        // Reload view here
                        let details = JSON(data)["content"]
                        self.chat!.id = details["conversationId"].int!
                    }
                    break
                case .failure(_):
                    print("Create conversation for New Sharre API failed")
                    break
                }
            }
        }
    }
    
    // MARK: Observer for messages
    private func getMessages() {
        let url = SharritURL.devURL + "message/" + String(describing: chat!.id!)
        
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
                        self.addMessage(withId: subJson["senderName"].description, name: subJson["senderName"].description, dateSent: subJson["dateCreated"].description, text: subJson["body"].description)
                    }
                }
                break
            case .failure(_):
                break
            }
        }
        finishReceivingMessage()
    }
    
    // Creation of Messages
    private func addMessage(withId id:String, name:String, dateSent: String, text:String) {
        // Format Date
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        let messageDate = dateFormatter2.date(from: dateSent)
        
        if let message = JSQMessage(senderId: id, senderDisplayName: name, date: messageDate, text: text) {
            messages.append(message)
        }
    }
    
    func addMedia(_ media:JSQMediaItem) {
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, media: media)!
        messages.append(message)
        finishSendingMessage(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewSharre" {
            if let viewSharreVC = segue.destination as? ViewSharreVC {
                viewSharreVC.sharreID = chat?.sharreID
            }
        }
    }
    
}

extension ConversationVC : CLLocationManagerDelegate {
    func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 1000
        locationManager.startUpdatingLocation()
    }
    
    // Provide current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        latitudeToSend = locationValue.latitude
        longitudeToSend = locationValue.longitude
        locationManager.stopUpdatingLocation()
        manager.delegate = nil;
        let locationItem = buildLocationItem(latitude: latitudeToSend!, longitude: longitudeToSend!)
        addMedia(locationItem)
    }
    
    // Print error if not able to update location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
    }
}

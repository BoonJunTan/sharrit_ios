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

final class ConversationVC: JSQMessagesViewController {
    
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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Setup for Conversation - Details
    var chat: Conversation? {
        didSet {
            title = chat?.conversationPartner
            senderId = String(describing: chat?.id)
            senderDisplayName = (appDelegate.user?.firstName)! + " " + (appDelegate.user?.lastName)!
            
            // TODO: Get and Change Avatar
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
        
        getMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        finishReceivingMessage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return messages[indexPath.item].senderId == self.senderId ? outgoingBubbleImageView : incomingBubbleImageView
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == "1" {
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
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
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
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    // MARK: Observer for messages
    private func getMessages() {
        // let url = "https://is41031718it02.southeastasia.cloudapp.azure.com/api/message/" + String(describing: chat!.id)
        let url = "http://localhost:5000/api/message/" + String(describing: chat!.id)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    for (_, subJson) in JSON(data) {
                        
                    }
                }
                break
            case .failure(_):
                break
            }
        }

        addMessage(withId: "1", name: "Dyllan", text: "Let's Meet")
        addMessage(withId: "2", name: "Ronald", text: "Lorem ipsum dolor sit amet, rebum nulla cum ei, usu ad erroribus gubergren. Id nec quaeque iudicabit. Eu eam dissentias omittantur theophrastus. Errem commodo usu ea. In eos noster debitis, at omnes nusquam mel.")
        addMessage(withId: "1", name: "Ronald", text: "Sure")
        addMessage(withId: "1", name: "Ronald", text: "Lorem ipsum dolor sit amet, rebum nulla cum ei, usu ad erroribus gubergren. Id nec quaeque iudicabit. Eu eam dissentias omittantur theophrastus. Errem commodo usu ea. In eos noster debitis, at omnes nusquam mel.")
        finishReceivingMessage()
    }
    
    // Creation of Messages
    private func addMessage(withId id:String, name:String, text:String){
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    func addMedia(_ media:JSQMediaItem) {
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, media: media)!
        messages.append(message)
        finishSendingMessage(animated: true)
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

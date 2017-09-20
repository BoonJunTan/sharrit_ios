//
//  SharrorFormVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 20/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SharrorFormVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var questionCollectionView: UICollectionView!
    var companyName: String!
    var companyId: Int!
    
    var questions:[String] = []

    @IBOutlet weak var succesfulApplicationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSBQuestions()
        
        self.title = "Sharror - " + companyName
        
        succesfulApplicationView.isHidden = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "formCell", for: indexPath as IndexPath) as! SharrorFormCollectionViewCell
        
        cell.questionLabel.text = questions[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: questionCollectionView.layer.frame.width,
                      height: questionCollectionView.layer.frame.height/3)
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
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if (section == 0) {
            return CGSize(width: questionCollectionView.layer.frame.width, height: 50)
        }
        return CGSize(width: questionCollectionView.layer.frame.width, height: 50 + 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerView", for: indexPath as IndexPath)
        
        return footerView
    }
    
    func getSBQuestions() {
        let url = SharritURL.devURL + "/requestform/" + String(describing: companyId)
        //let url = "http://ee081d4f.ngrok.io/api/requestform/1"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    for (_, subJson) in JSON(data)["content"] {
                        let stringQuestion = subJson["question"].string!
                        if let convertedQuestion = stringQuestion.data(using: String.Encoding.utf8) {
                            do {
                                let dictionary = try JSONSerialization.jsonObject(with: convertedQuestion, options: []) as? [String:AnyObject]
                                for (_, question) in dictionary! {
                                    self.questions.append(question as! String)
                                }
                                self.questionCollectionView.reloadData()
                            } catch let error as NSError {
                                print("Error converting string to json")
                            }
                        }
                    }
                }
                break
            case .failure(_):
                print("Retrieve Sharing Business Questions API failed")
                break
            }
        }
    }
    
    @IBAction func submitFormBtnTapped(_ sender: SharritButton) {
        
        var answer = [String : String]()
        
        for cell in questionCollectionView.visibleCells as! [SharrorFormCollectionViewCell] {
            answer[cell.questionLabel.text!] = cell.answerText.text
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let url = SharritURL.devURL + "/answer/" + String(describing: companyId) + "/user" + String(describing: appDelegate.user!.userID)
        
        //let url = "http://ee081d4f.ngrok.io/api/answer/1/user/5"
        
        let parameter: [String: Any] = ["answer": answer]
        
        Alamofire.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                // Redirect to success
                self.succesfulApplicationView.isHidden = false
                UIView.animate(withDuration: 5, animations: {
                    self.succesfulApplicationView.alpha = 0
                }) { (finished) in
                    self.succesfulApplicationView.alpha = 1
                    self.succesfulApplicationView.isHidden = true
                    self.navigationController?.popViewController(animated: true)
                }
                break
            case .failure(_):
                print("Sharror request form API failed")
                break
            }
        }
    }
    
}

//
//  SharreBookingVC.swift
//  sharrit-ios
//
//  Created by Boon Jun on 28/9/17.
//  Copyright © 2017 thepoppingone. All rights reserved.
//

import UIKit
import FSCalendar
import Alamofire
import SwiftyJSON
import DropDown

class SharreBookingVC: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // Pass Over Data
    var sharreID: Int!
    var sharreTitle: String!
    var appointmentType: SharresType!
    var sharreStartTime: String!
    var sharreEndTime: String!
    
    @IBOutlet weak var unitRequire: UITextField!
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarView: UIView!
    
    var timeCollection: [TimeSlot]! = [] // Operating Hours
    var selectedTimeSlot: [Int]! = []
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var timeSlotView: UIView!
    @IBOutlet weak var timeSlotHeight: NSLayoutConstraint!
    
    @IBOutlet weak var costView: UIView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // Automatically get local - E.g. Asia/Singapore (current time)
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = sharreTitle
        
        unitRequire.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        setUpCalendar()
        collectionView.allowsMultipleSelection = true
        calendarView.isHidden = true
        timeSlotView.isHidden = true
        costView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if !(textField.text?.isEmpty)! {
            if appointmentType == .DayAppointment {
                getAvailableSlot()
            } else {
                calendarView.isHidden = false
            }
        } else {
            calendarView.isHidden = true
        }
    }
    
    // Setup Calendar - For Appointment Based
    func setUpCalendar() {
        if appointmentType == .DayAppointment {
            calendar.swipeToChooseGesture.isEnabled = true
            calendar.allowsMultipleSelection = true
        } else {
            calendar.swipeToChooseGesture.isEnabled = false
            calendar.allowsMultipleSelection = false
        }
    }
    
    // FSCalendar Delegate Method
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("Did select date \(self.formatter.string(from: date))")
        if appointmentType == .HrAppointment {
            getAvailableSlot()
        } else {
            costView.isHidden = false
        }
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        print("Did deselect date \(self.formatter.string(from: date))")
    }
    
    // MARK: - Setup Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let timeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeCell", for: indexPath as IndexPath) as! TimeCollectionViewCell
        
        timeCell.tickImage.isHidden = true
        timeCell.timeLabel.text = FormatDate().generateTimeHrMin(rangeStart: timeCollection[indexPath.item].timeStart, rangeEnd: timeCollection[indexPath.item].timeEnd)
        timeCell.unitLabel.text = "(" + String(describing: timeCollection[indexPath.item].quantity) + ") left"
        
        return timeCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.layer.frame.width/3 - 10,
                      height: collectionView.layer.frame.height/3 - 5)
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
        
        let totalCellWidth = collectionView.layer.frame.width - 5
        
        let leftInset = (collectionView.layer.frame.width - CGFloat(totalCellWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(leftInset, leftInset, leftInset, rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !selectedTimeSlot.isEmpty {
            if selectedTimeSlot.contains(indexPath.item-1) || selectedTimeSlot.contains(indexPath.item+1) {
                selectedTimeSlot.append(indexPath.item)
                let timeCell = collectionView.cellForItem(at: indexPath) as! TimeCollectionViewCell
                timeCell.tickImage.isHidden = !timeCell.tickImage.isHidden
                
                costView.isHidden = false
            } else {
                let alert = UIAlertController(title: "Error Occured!", message: "You must select consecutive time-slot", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            selectedTimeSlot.append(indexPath.item)
            let timeCell = collectionView.cellForItem(at: indexPath) as! TimeCollectionViewCell
            timeCell.tickImage.isHidden = !timeCell.tickImage.isHidden
            
            costView.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,didDeselectItemAt indexPath: IndexPath) {
        if selectedTimeSlot.count != 1 {
            if selectedTimeSlot.contains(indexPath.item-1) && selectedTimeSlot.contains(indexPath.item+1) {
                let alert = UIAlertController(title: "Error Occured!", message: "You cannot remove a center time-slot", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                if let index = selectedTimeSlot.index(of: indexPath.item) {
                    selectedTimeSlot.remove(at: index)
                    let timeCell = collectionView.cellForItem(at: indexPath) as! TimeCollectionViewCell
                    timeCell.tickImage.isHidden = !timeCell.tickImage.isHidden
                }
            }
        } else {
            if let index = selectedTimeSlot.index(of: indexPath.item) {
                selectedTimeSlot.remove(at: index)
                let timeCell = collectionView.cellForItem(at: indexPath) as! TimeCollectionViewCell
                timeCell.tickImage.isHidden = !timeCell.tickImage.isHidden
            }
        }
    }
    
    func getAvailableSlot() {
        let url = SharritURL.devURL + "sharre/avail/schedule/" + String(describing: sharreID!)
        
        let timestamp = NSDate().timeIntervalSince1970
        
        let filterData: [String: Any] = ["timeStart": timestamp]
        
        Alamofire.request(url, method: .post, parameters: filterData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    if self.appointmentType == .HrAppointment {
                        self.timeCollection = []
                        for (_, subJson) in JSON(data)["content"] {
                            let rangeStart = subJson["rangeStart"].description
                            let rangeEnd = subJson["rangeEnd"].description
                            let quantity = subJson["qty"].int!
                            let timeSlot = TimeSlot(timeStart: rangeStart, timeEnd: rangeEnd, quantity: quantity)
                            
                            self.timeCollection.append(timeSlot)
                        }
                        self.timeSlotView.isHidden = false
                        self.collectionView.reloadData()
                    }
                }
                break
            case .failure(_):
                print("Get Time Slot Info API failed")
                break
            }
        }
    }

    @IBAction func bookBtnPressed(_ sender: SharritButton) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

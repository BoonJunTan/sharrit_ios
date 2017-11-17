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

class SharreBookingVC: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // Pass Over Data
    var sharreID: Int!
    var sharreTitle: String!
    var sharreDescription: String!
    var sharreImageURL: String?
    var appointmentType: SharresType!
    var sharreStartTime: String!
    var sharreEndTime: String!
    var sharreDeposit: String!
    var ownerName: String!
    var ownerID: Int!
    var ownerType: Int!
    var collaborationList: [JSON]?
    var collabID: Int?
    
    @IBOutlet weak var unitRequire: UITextField!
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarView: UIView!
    var dateSelected: String!
    var dateCollection: [DateSlot]! = [] // Operating Date
    var currentSelectedMonth = Date()
    var selectedDateSlot: [Int]! = []
    var selectedDateSlotObject: [Date]! = []
    
    var timeCollection: [TimeSlot]! = [] // Operating Hours
    var selectedTimeSlot: [Int]! = []
    var selectedTimeSlotObject: [TimeSlot]! = []
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var timeSlotView: UIView!
    @IBOutlet weak var timeSlotHeight: NSLayoutConstraint!
    
    @IBOutlet weak var promoView: UIView!
    @IBOutlet weak var promoAppliedLabel: UILabel!
    @IBOutlet weak var promoLabel: UITextField!
    
    @IBOutlet weak var costView: UIView!
    @IBOutlet weak var deposit: UILabel!
    @IBOutlet weak var usage: UILabel!
    
    // Usage with Promo
    let attributeUsageTitle: NSMutableAttributedString = NSMutableAttributedString(string: "Usage: $")
    var attributeTotalAmount: NSMutableAttributedString?
    var attributeDiscountAmount: NSMutableAttributedString?
    
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var bookBtn: SharritButton!
    
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
        deposit.text = "Deposit: $" + sharreDeposit
        
        unitRequire.keyboardType = .numberPad
        unitRequire.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        setUpCalendar()
        collectionView.allowsMultipleSelection = true
        calendarView.isHidden = true
        timeSlotView.isHidden = true
        promoAppliedLabel.isHidden = true
        promoView.isHidden = true
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
        dateSelected = formatter.string(from: date)
        if appointmentType == .HrAppointment {
            getAvailableSlot()
        } else {
            promoView.isHidden = false
            costView.isHidden = false
        }
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let today = Date()
        let ytd = Calendar.current.date(byAdding: .day, value: -1, to: today)
        if date < ytd! {
            return false
        }
        
        // Additional for Day Appointment
        if appointmentType == .DayAppointment {
            let calendar = Calendar.current
            let correctDate = calendar.date(byAdding: .hour, value: 8, to: date)
            for dateObject in dateCollection {
                if Calendar.current.isDate(correctDate!, inSameDayAs: FormatDate().formatDateTimeToLocal2(date: dateObject.dateStart)) {
                    if dateObject.quantity < Int(unitRequire.text!)! {
                        return false
                    }
                }
            }
            
            if !selectedDateSlotObject.isEmpty {
                for currentDate in selectedDateSlotObject {
                    let date1 = calendar.startOfDay(for: currentDate)
                    let date2 = calendar.startOfDay(for: date)
                    
                    let components = calendar.dateComponents([.day], from: date1, to: date2)
                    let components2 = calendar.dateComponents([.day], from: date2, to: date1)
                    
                    if components.day == 1 || components2.day == 1 {
                        selectedDateSlotObject.append(date)
                        getTotalCost()
                        return true
                    }
                }
                
                let alert = UIAlertController(title: "Error Occured!", message: "You must select consecutive time-slot", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return false
            } else {
                selectedDateSlotObject.append(date)
            }
            getTotalCost()
        }
        return true
    }
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        if appointmentType == .DayAppointment {
            if selectedDateSlotObject.count != 1 {
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date)
                let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: date)
                
                if selectedDateSlotObject.contains(tomorrow!) && selectedDateSlotObject.contains(dayBefore!) {
                    let alert = UIAlertController(title: "Error Occured!", message: "You cannot remove a center time-slot", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return false
                }
                
                if let index = selectedDateSlotObject.index(of: date) {
                    selectedDateSlotObject.remove(at: index)
                }
            } else {
                if let index = selectedDateSlotObject.index(of: date) {
                    selectedDateSlotObject.remove(at: index)
                }
            }
            getTotalCost()
        }
        return true
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let today = Date()
        let ytd = Calendar.current.date(byAdding: .day, value: -1, to: today)
        if self.gregorian.isDateInToday(date) {
            return UIColor.white
        }
        if date < ytd! {
            return UIColor.lightGray
        }
        
        // Additional for Day Appointment
        if appointmentType == .DayAppointment {
            let calendar = Calendar.current
            let correctDate = calendar.date(byAdding: .hour, value: 8, to: date)
            for dateObject in dateCollection {
                if Calendar.current.isDate(correctDate!, inSameDayAs: FormatDate().formatDateTimeToLocal2(date: dateObject.dateStart)) {
                    if dateObject.quantity < Int(unitRequire.text!)! {
                        return UIColor.lightGray
                    }
                }
            }
        }
        return UIColor.black
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        print("Did deselect date \(self.formatter.string(from: date))")
    }
    
    func calendarCurrentMonthDidChange(_ calendar: FSCalendar) {
        let calendarType = Calendar.current
        let correctMonth = calendarType.date(byAdding: .hour, value: 8, to: calendar.currentPage)
        currentSelectedMonth = correctMonth!
        getAvailableSlot()
    }
    
    // MARK: - Setup Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if timeCollection[indexPath.item].quantity < Int(unitRequire.text!)! {
            let timeCell = collectionView.cellForItem(at: indexPath) as! TimeCollectionViewCell
            timeCell.isUserInteractionEnabled = false
            let alert = UIAlertController(title: "Error Occured!", message: "Not Enough Quantity", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let timeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeCell", for: indexPath as IndexPath) as! TimeCollectionViewCell
        
        timeCell.timeLabel.text = FormatDate().generateTimeHrMin(rangeStart: timeCollection[indexPath.item].timeStart, rangeEnd: timeCollection[indexPath.item].timeEnd)
        timeCell.unitLabel.text = "(" + String(describing: timeCollection[indexPath.item].quantity) + ") left"
        
        if selectedTimeSlot.contains(indexPath.item) {
            timeCell.tickImage.isHidden = false
        } else {
            timeCell.tickImage.isHidden = true
        }
        
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
        let timeCell = collectionView.cellForItem(at: indexPath) as! TimeCollectionViewCell
        if !selectedTimeSlot.isEmpty {
            if selectedTimeSlot.contains(indexPath.item-1) || selectedTimeSlot.contains(indexPath.item+1) {
                selectedTimeSlot.append(indexPath.item)
                selectedTimeSlotObject.append(timeCollection[indexPath.item])
                timeCell.tickImage.isHidden = !timeCell.tickImage.isHidden
            } else {
                let alert = UIAlertController(title: "Error Occured!", message: "You must select consecutive time-slot", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: { (_) in
                    timeCell.isSelected = false
                }))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            selectedTimeSlot.append(indexPath.item)
            selectedTimeSlotObject.append(timeCollection[indexPath.item])
            timeCell.tickImage.isHidden = !timeCell.tickImage.isHidden
            timeCell.isSelected = true
        }
        getTotalCost()
    }
    
    func collectionView(_ collectionView: UICollectionView,didDeselectItemAt indexPath: IndexPath) {
        let timeCell = collectionView.cellForItem(at: indexPath) as! TimeCollectionViewCell
        if selectedTimeSlot.count != 1 {
            if selectedTimeSlot.contains(indexPath.item-1) && selectedTimeSlot.contains(indexPath.item+1) {
                let alert = UIAlertController(title: "Error Occured!", message: "You cannot remove a center time-slot", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: { (_) in
                    timeCell.isSelected = true
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                if let index = selectedTimeSlot.index(of: indexPath.item) {
                    selectedTimeSlot.remove(at: index)
                    selectedTimeSlotObject.remove(at: index)
                    timeCell.tickImage.isHidden = !timeCell.tickImage.isHidden
                    timeCell.isSelected = false
                }
            }
        } else {
            if let index = selectedTimeSlot.index(of: indexPath.item) {
                selectedTimeSlot.remove(at: index)
                selectedTimeSlotObject.remove(at: index)
                timeCell.tickImage.isHidden = !timeCell.tickImage.isHidden
                timeCell.isSelected = false
            }
        }
        getTotalCost()
    }
    
    func getAvailableSlot() {
        usage.text = "Usage: $0"
        total.text = "Total: $" + sharreDeposit
        
        let url = SharritURL.devURL + "sharre/avail/schedule/" + String(describing: sharreID!)
        
        var scheduleData: [String: Any] = [:]
        if appointmentType == .HrAppointment {
            let timestamp = FormatDate().formatDateTimeToLocal(date: dateSelected).timeIntervalSince1970
            scheduleData["timeStart"] = Int64(timestamp)
        } else {
            let timestamp = currentSelectedMonth.timeIntervalSince1970
            scheduleData["timeStart"] = Int64(timestamp)
        }
        
        Alamofire.request(url, method: .post, parameters: scheduleData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    if self.appointmentType == .HrAppointment {
                        self.timeCollection = []
                        self.selectedTimeSlot = []
                        self.selectedTimeSlotObject = []
                        for (_, subJson) in JSON(data)["content"] {
                            let rangeStart = subJson["rangeStart"].description
                            let rangeEnd = subJson["rangeEnd"].description
                            let quantity = subJson["qty"].int!
                            let timeSlot = TimeSlot(timeStart: rangeStart, timeEnd: rangeEnd, quantity: quantity)
                            
                            self.timeCollection.append(timeSlot)
                        }
                        self.timeSlotView.isHidden = false
                        self.collectionView.reloadData()
                    } else {
                        self.dateCollection = []
                        for (_, subJson) in JSON(data)["content"] {
                            let rangeStart = subJson["rangeStart"].description
                            let quantity = subJson["qty"].int!
                            let dateSlot = DateSlot(dateStart: rangeStart, quantity: quantity)
                            
                            self.dateCollection.append(dateSlot)
                            
                        }
                        self.calendarView.isHidden = false
                        self.calendar.reloadData()
                    }
                }
                break
            case .failure(_):
                print("Get Time Slot Info API failed")
                self.calendarView.isHidden = true
                break
            }
        }
    }
    
    func getTotalCost() {
        if (selectedTimeSlot.isEmpty && appointmentType == .HrAppointment) || (selectedDateSlotObject.isEmpty && appointmentType == .DayAppointment) {
            deposit.text = "Deposit: $" + sharreDeposit
            usage.text = "Usage: $0"
            total.text = "Total: $" + sharreDeposit
            costView.isHidden = false
            promoView.isHidden = false
            bookBtn.isEnabled = false
        } else {
            let url = SharritURL.devURL + "transaction/pricing/" + String(describing: sharreID!) + "/" + String(describing: appDelegate.user!.userID)
            
            let timeStart:Double
            let timeEnd:Double
            
            if appointmentType == .HrAppointment {
                selectedTimeSlot.sort {$0 < $1}
                
                timeStart = FormatDate().formatDateTimeToLocal2(date: selectedTimeSlotObject[0].timeStart).timeIntervalSince1970
                timeEnd = FormatDate().formatDateTimeToLocal2(date: selectedTimeSlotObject[selectedTimeSlotObject.count - 1].timeEnd).timeIntervalSince1970
            } else {
                timeStart = selectedDateSlotObject[0].timeIntervalSince1970
                let timeEndTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDateSlotObject[selectedDateSlotObject.count - 1])
                timeEnd = timeEndTomorrow!.timeIntervalSince1970
            }
            
            var totalCostRequest: [String: Any] = ["qty": unitRequire.text!, "timeStart": Int64(timeStart), "timeEnd": Int64(timeEnd)]
            
            if !(promoLabel.text?.isEmpty)! {
                totalCostRequest["promoCode"] = promoLabel.text!
            }
            
            Alamofire.request(url, method: .post, parameters: totalCostRequest, encoding: JSONEncoding.default, headers: [:]).responseJSON {
                response in
                switch response.result {
                case .success(_):
                    if let data = response.result.value {
                        if JSON(data)["status"].int! == -1 {
                            self.promoAppliedLabel.isHidden = true
                            let alert = UIAlertController(title: "Error Occured!", message: "Promo Code is invalid", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: { (_) in
                                self.promoLabel.text = ""
                            }))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            let json = JSON(data)["content"]
                            
                            if (self.promoLabel.text?.isEmpty)! {
                                self.usage.text = "Usage: $" + json["totalAmount"].description
                                let totalCostDouble = Double(json["totalDeposit"].description)! + Double(json["totalAmount"].description)!
                                let totalCost = FormatNumber().giveTwoDP(number: NSNumber(value: totalCostDouble))
                                self.total.text = "Total: $" + totalCost
                            } else {
                                self.attributeTotalAmount = NSMutableAttributedString(string: json["totalAmount"].description + " ")
                                self.attributeTotalAmount!.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, self.attributeTotalAmount!.length))
                                self.attributeTotalAmount!.addAttribute(NSStrikethroughColorAttributeName, value: UIColor.red, range: NSMakeRange(0, self.attributeTotalAmount!.length))
                                
                                self.attributeDiscountAmount = NSMutableAttributedString(string: json["discountAmount"].description)
                                
                                let myString:NSMutableAttributedString = self.attributeUsageTitle
                                myString.append(self.attributeTotalAmount!)
                                myString.append(self.attributeDiscountAmount!)
                                
                                self.usage.attributedText = myString
                                let totalCostDouble = Double(json["totalDeposit"].description)! + Double(json["discountAmount"].description)!
                                let totalCost = FormatNumber().giveTwoDP(number: NSNumber(value: totalCostDouble))
                                self.total.text = "Total: $" + totalCost
                            }
                            
                            self.deposit.text = "Deposit: $" + json["totalDeposit"].description
                            
                            if !(self.promoLabel.text?.isEmpty)! {
                                self.promoAppliedLabel.isHidden = false
                            } else {
                                self.promoAppliedLabel.isHidden = true
                            }
                            
                            self.costView.isHidden = false
                            self.promoView.isHidden = false
                            self.bookBtn.isEnabled = true
                        }
                    }
                    break
                case .failure(_):
                    print("Get Total Cost Info API failed")
                    break
                }
            }
        }
    }
    
    @IBAction func enterPromoBtnPressed(_ sender: SharritButton) {
        getTotalCost()
    }

    @IBAction func bookBtnPressed(_ sender: SharritButton) {
        let depositCost = deposit.text!.replacingOccurrences(of: "Deposit: $", with: "")
        
        let url = SharritURL.devURL + "transaction/" + String(describing: sharreID!)
        
        let timeStart:Double
        let timeEnd:Double
        
        if appointmentType == .HrAppointment {
            selectedTimeSlot.sort {$0 < $1}
            
            timeStart = FormatDate().formatDateTimeToLocal2(date: selectedTimeSlotObject[0].timeStart).timeIntervalSince1970
            timeEnd = FormatDate().formatDateTimeToLocal2(date: selectedTimeSlotObject[selectedTimeSlotObject.count - 1].timeEnd).timeIntervalSince1970
        } else {
            timeStart = selectedDateSlotObject[0].timeIntervalSince1970
            let timeEndTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDateSlotObject[selectedDateSlotObject.count - 1])
            timeEnd = timeEndTomorrow!.timeIntervalSince1970
        }
        
        var transactionData: [String: Any] = ["payerId": appDelegate.user!.userID, "payerType": 0, "deposit": depositCost, "timeStart": Int64(timeStart), "timeEnd": Int64(timeEnd), "qty": unitRequire.text!]
        
        if !(promoLabel.text?.isEmpty)! {
            transactionData["promoCode"] = promoLabel.text!
            transactionData["amount"] = String(describing: attributeDiscountAmount!).replacingOccurrences(of: "{\n}", with: "")
        } else {
            let usageCost = usage.text!.replacingOccurrences(of: "Usage: $", with: "")
            transactionData["amount"] = usageCost
        }
        
        if collabID != nil {
            transactionData["collabId"] = collabID
        }
        
        Alamofire.request(url, method: .post, parameters: transactionData, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            switch response.result {
            case .success(_):
                if let data = response.result.value {
                    var json = JSON(data)
                    if json["status"] == 1 {
                        self.performSegue(withIdentifier: "viewSuccessful", sender: nil)
                    } else {
                        let alert = UIAlertController(title: "Error Occured!", message: "You do not have enough money in Wallet", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                        alert.addAction(UIAlertAction(title: "Wallet", style: .default, handler: { (_) in
                            self.tabBarController?.selectedIndex = 1
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                break
            case .failure(_):
                print("Transaction Submission API failed")
                break
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewSuccessful" {
            if let successfulBookingVC = segue.destination as? SuccessfulBookingVC {
                successfulBookingVC.receiverName = ownerName
                successfulBookingVC.receiverID = ownerID
                successfulBookingVC.receiverType = ownerType
                successfulBookingVC.sharreTitle = sharreTitle
                successfulBookingVC.sharreID = sharreID
                successfulBookingVC.sharreDescription = sharreDescription
                successfulBookingVC.sharreImageURL = sharreImageURL
                if collaborationList != nil {
                    successfulBookingVC.collaborationList = collaborationList
                }
            }
        }
    }
}

//
//  CalendarNewExperimentViewController.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/4/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit
import JTAppleCalendar

class CalendarNewExperimentViewController : UIViewController {
    
    //OUTLETS
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var confirmDates: UIButton!
    
    //VARIABLES
    
    let formatter = DateFormatter()

    //OVERRIDE FUNCTIONS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendar()
        self.tabBarController?.tabBar.isHidden = true
        self.confirmDates.isHidden = true
        self.confirmDates.backgroundColor = UIColor.red
    }
    
    //IBACTION
    
    @IBAction func backToExp(_ sender: Any) {
        
        performSegue(withIdentifier: "backToExperiment", sender: nil)

    }
    
    //CONVENIENCE FUNCTIONS
    
    func setupCalendar() {
        calendarView.minimumInteritemSpacing = 0
        calendarView.minimumLineSpacing = 0
        
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }

    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CustomCell else {return}
        if cellState.isSelected {
            validCell.selectedView.isHidden = false
        } else {
            validCell.selectedView.isHidden = true
        }
    }
    
    func handCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CustomCell else {return}
        validCell.dateLabel.text = cellState.text

        if cellState.isSelected {
            validCell.dateLabel.textColor = UIColor.red
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLabel.textColor = UIColor.white
            } else {
                validCell.dateLabel.textColor = UIColor.gray
            }
        }
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        
        let date = visibleDates.monthDates.first!.date
        
        self.formatter.dateFormat = "yyyy"
        self.year.text = self.formatter.string(from: date)
        
        self.formatter.dateFormat = "MMMM"
        self.month.text = self.formatter.string(from: date)
    }
    
    func alertError(_ controller: UIViewController, error: String) {
        let alertView = UIAlertController(title: "", message: error, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        controller.present(alertView, animated: true, completion: nil)
    }
    
    //PUSH DATA BACK TO NEWEXPVC
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToExperiment" {
            if let vc = segue.destination as? NewExperimentalViewController {
                let startText = self.startTextField.text as! String
                vc.startDate = startText
                let endText = self.endDateTextField.text as! String
                vc.endDate = endText
                
                
            }
        }
    }
}


//SETTING UP JTCALENDARVIEW

extension CalendarNewExperimentViewController: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2018 03 01")!
        let endDate = formatter.date(from: "2018 06 01")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let myCustomCell = cell as! CustomCell
        sharedFunctionToConfigureCell(myCustomCell: myCustomCell, cellState: cellState, date: date)
    }
    
    func sharedFunctionToConfigureCell(myCustomCell: CustomCell, cellState: CellState, date: Date) {

        handCellTextColor(view: myCustomCell, cellState: cellState)
        handleCellSelected(view: myCustomCell, cellState: cellState)
    }
    
}

extension CalendarNewExperimentViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let myCustomCell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        sharedFunctionToConfigureCell(myCustomCell: myCustomCell, cellState: cellState, date: date)
        return myCustomCell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handCellTextColor(view: cell, cellState: cellState)
        calendar.allowsMultipleSelection = true
        
        if calendar.selectedDates.count > 2 {
            alertError(self, error: "Please select TWO dates: A start date and an end date for your experiment")
            self.calendarView.deselectAllDates()
            self.startTextField.text = ""
            self.endDateTextField.text = ""
            self.confirmDates.isHidden = true
            }
       
        formatter.dateFormat = "MM dd YYYY"
        
        if calendar.selectedDates.count == 2 {
            let startDate = calendar.selectedDates[0]
            self.startTextField.text = self.formatter.string(from: startDate)
            self.startTextField.textColor = UIColor.red
            self.startTextField.isHidden = false
            
            let endDate = calendar.selectedDates[1]
            self.endDateTextField.text = self.formatter.string(from: endDate)
            self.endDateTextField.textColor = UIColor.red
            self.endDateTextField.isHidden = false
            
            self.confirmDates.isHidden = false
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
}

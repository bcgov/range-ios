//
//  DatePickerViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-05-01.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController, Theme {

    // MARK: Constants
    let suggestedWidth = 250
    let suggestedHeight = 200

    // MARK: Variables
    var completion: ((_ result: Date) -> Void )?
    var listCompletion: ((_ result: String) -> Void )?
    var listPickerList: [String] = [String]()

    var isListMode: Bool = false

    var min: Date?
    var max: Date?

    var selectedDate: Date? {
        didSet{
            selectButton.alpha = 1
            selectButton.isEnabled = true
        }
    }
    var selectedListItem: String? {
        didSet{
            selectButton.alpha = 1
            selectButton.isEnabled = true
        }
    }

    // MARK: Outlets
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var listPicker: UIPickerView!
    @IBOutlet weak var selectButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        selectButton.isEnabled = false
        selectButton.alpha = 0.5
        if isListMode {
            showListPicker()
        } else {
            showDatePicker()
        }
    }

    // MARK: Outlet Functions

    // TODO: Handle case where there is only 1 item and user wont scroll
    @IBAction func selectAction(_ sender: UIButton) {
        if isListMode, let listCallBack = listCompletion, let listSelection = selectedListItem {
            self.dismiss(animated: true, completion: {
                return listCallBack(listSelection)
            })
        }

        if !isListMode, let dateCallBack = completion, let dateSelection = selectedDate {
            self.dismiss(animated: true, completion: {
                return dateCallBack(dateSelection)
            })
        }
    }

    @IBAction func valueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }

    // MARK: Functions

    // MARK: Setup

    // Used by Basic infomation section
    // full date selection between specified dates
    func setup(min: Date, max: Date, completion: @escaping (_ result: Date) -> Void) {
        self.completion = completion
        self.min = min
        self.max = max

        isListMode = false
    }

    // Used by schedule page: Only allow dates within year,
    func setup(for year: Int, minDate: Date?, completion: @escaping (_ result: Date) -> Void) {
        self.completion = completion
        if let m = minDate {
            self.min = m
        } else {
            self.min = getFirstDateOf(year: year)
        }
        self.max = getLastDateOf(year: year)

        isListMode = false
    }

    // Used by schedule section
    func setup(for min: Date, max: Date, taken: [String],completion: @escaping (_ result: String) -> Void) {
        self.listCompletion = completion
        let minYear = Calendar.current.component(.year, from: min)
        let maxYear = Calendar.current.component(.year, from: max)

        listPickerList = [String]()
        for i in minYear...maxYear {
            let yearString = "\(i)"
            if !taken.contains(yearString) {
                listPickerList.append(yearString)
            }
        }

        isListMode = true
    }

    // MARK: Utility functions
    func getLastDateOf(year: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = 12
        dateComponents.day = 31
        dateComponents.timeZone = TimeZone.current
        dateComponents.hour = 0
        dateComponents.minute = 0
        if let date = Calendar.current.date(from: dateComponents) {
            return date
        } else {
            return Date()
        }
    }

    func getFirstDateOf(year: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.timeZone = TimeZone.current
        dateComponents.hour = 0
        dateComponents.minute = 0
        if let date = Calendar.current.date(from: dateComponents) {
            return date
        } else {
            return Date()
        }
    }

    func showDatePicker() {
        guard let minDate = min, let maxDate = max else {return}
        picker.minimumDate = minDate
        picker.maximumDate = maxDate
        picker.datePickerMode = .date
        self.picker.alpha = 1
        self.listPicker.alpha = 0
        picker.setDate(minDate, animated: true)
        selectedDate = minDate
    }

    func showListPicker() {
        self.picker.alpha = 0
        self.listPicker.alpha = 1
        setupListPicker()
        if listPickerList.count > 0 {
            listPicker.selectRow(0, inComponent: 0, animated: true)
            selectedListItem = listPickerList.first
        }
    }

    // MARK: Styles
    func style() {
        styleFillButton(button: selectButton)
    }

}


// MARK: ListPicker
extension DatePickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func setupListPicker() {
        listPicker.delegate = self
        listPicker.dataSource = self
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if listPickerList.isEmpty {return}
        if listPickerList.count >= row {
            selectedListItem = listPickerList[row]
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listPickerList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return listPickerList[row]
    }
}

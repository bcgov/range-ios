//
//  PlanAndAgreementDateTests.swift
//  MyraTests
//
//  Created by Wells, Micheal W IIT:EX on 2019-10-04.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import XCTest
import Fakery
import SwiftyJSON
@testable import Myra
import Realm
import RealmSwift
import FileToJson

class PlanAndAgreementDateTests: XCTestCase {


        
        static var faker = Faker()
        var app: XCUIApplication!
        

        
        
        override func setUp() {
            MyraTests.faker = Faker(locale: "en-CA")
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
            }
            //self.app = XCUIApplication
            //self.app.launch()
            
        }
        
        func test_Can_Create_Valid_Mock_Agreement() {
            guard let jsonObj = MyraTests.helper_readJSONFromFile(fileName: "AgreementData", fileExtension: "json") else {
                fatalError("unable to load json")
            }
            
            let agreement = Agreement(json: jsonObj)
            
            XCTAssert(agreement.agreementStartDate != nil)
        }
        
        func test_Can_Create_RUP_From_Mock_Agreement() {
            
            // set up test agreement
            guard let jsonObj = MyraTests.helper_readJSONFromFile(fileName: "AgreementData", fileExtension: "json") else {
                fatalError("unable to load json")
            }
            let agreement = Agreement(json: jsonObj)
            
            // create base RUP as done in select agreement view controller:
            let plan = RUPManager.shared.genRUP(forAgreement: agreement)
            
            
            XCTAssert(plan.agreementEndDate == agreement.agreementEndDate)
            print("banana")
        }
        
        
        func test_Can_Set_RUP_Start_Date_Past_Agreement_End_Date() {
            //get date formatter ready to set plan dates
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            // set up test agreement
            guard var jsonObj = MyraTests.helper_readJSONFromFile(fileName: "AgreementData", fileExtension: "json") else {
                fatalError("unable to load json")
            }
            //overwrite the dates to work for this test:
            jsonObj["agreementStartDate"] = "2040-12-31T08:00:00.000Z"
            jsonObj["agreementEndDate"] = "2041-12-31T08:00:00.000Z"
            let agreement = Agreement(json: jsonObj)
            
            // create base RUP as done in select agreement view controller:
            let plan = RUPManager.shared.genRUP(forAgreement: agreement)
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "CreateNewRup", bundle: nil)
            var rupController = storyBoard.instantiateViewController(withIdentifier: "CreateNewRup") as! CreateNewRUPViewController
            
            rupController.setup(rup: plan, mode: .Edit)
            rupController.loadView()
            rupController.setUpTable()
            rupController.viewDidLoad()
            
            // get tableview cell with plan info and set dates
            let indexPath = IndexPath(item: 1, section: 0)
            let planInfoCell = rupController.tableView.cellForRow(at: indexPath) as! PlanInformationTableViewCell?
            planInfoCell?.setup(mode: .Edit, rup: rupController.rup!)
            
            planInfoCell!.handlePlanEndDate(date: dateFormatter.date(from: "25/01/2050")!)
            planInfoCell!.handlePlanStartDate(date: dateFormatter.date(from: "25/01/2051")!)
            
            XCTAssert( planInfoCell!.plan!.planStartDate! > agreement.agreementEndDate!)
        }
        
        func test_Can_Set_RUP_End_Date_Past_Agreement_End_Date() {
            //get date formatter ready to set plan dates
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            // set up test agreement
            guard var jsonObj = MyraTests.helper_readJSONFromFile(fileName: "AgreementData", fileExtension: "json") else {
                fatalError("unable to load json")
            }
            //overwrite the dates to work for this test:
            jsonObj["agreementStartDate"] = "2040-12-31T08:00:00.000Z"
            jsonObj["agreementEndDate"] = "2041-12-31T08:00:00.000Z"
            let agreement = Agreement(json: jsonObj)
            
            // create base RUP as done in select agreement view controller:
            let plan = RUPManager.shared.genRUP(forAgreement: agreement)
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "CreateNewRup", bundle: nil)
            var rupController = storyBoard.instantiateViewController(withIdentifier: "CreateNewRup") as! CreateNewRUPViewController
            
            rupController.setup(rup: plan, mode: .Edit)
            rupController.loadView()
            rupController.setUpTable()
            rupController.viewDidLoad()
            
            // get tableview cell with plan info and set dates
            let indexPath = IndexPath(item: 1, section: 0)
            let planInfoCell = rupController.tableView.cellForRow(at: indexPath) as! PlanInformationTableViewCell?
            planInfoCell?.setup(mode: .Edit, rup: rupController.rup!)
            
            planInfoCell!.handlePlanEndDate(date: dateFormatter.date(from: "25/01/2050")!)
            planInfoCell!.handlePlanStartDate(date: dateFormatter.date(from: "25/01/2051")!)
            
            XCTAssert( planInfoCell!.plan!.planEndDate! > agreement.agreementEndDate!)
        }
        
        func test_Can_Create_Usage_data_extending_past_agreement_to_RUP_end_date()
        {
            XCTAssert(false)
        }
        
        func test_Can_Identify_date_in_usage_period_as_FTA_set_or_Extended()
        {
            XCTAssert(false)
        }
        
        
        
        
        
        
        
        
        
        
        // UI tests
        func test_Can_launch_app() {
            XCTAssert(false)
        }
        override func tearDown() {
            // Put teardown code here. This method is called after the invocation of each test method in the class.
        }
        
        
        
}

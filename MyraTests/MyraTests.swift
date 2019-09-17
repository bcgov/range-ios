//
//  MyraTests.swift
//  MyraTests
//
//  Created by Wells, Micheal W IIT:EX on 2019-09-16.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import XCTest
import Fakery
import SwiftyJSON



class MyraTests: XCTestCase {
   
    static var faker = Faker()
    
    static func helper_readJSONFromFile(fileName: String) -> JSON?
    {
        guard let pathString = Bundle(for: type(of: self) as! AnyClass).path(forResource: fileName, ofType: "json") else {
            fatalError(fileName + "  not found")
        }
        
        guard let jsonString = try? NSString(contentsOfFile: pathString, encoding: String.Encoding.utf8.rawValue) as String else {
            fatalError("Unable to convert " + fileName + " to String")
        }
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            fatalError("cant serialize json")
        }
        
        guard let jsonObj = try? JSON(data: jsonData) else {fatalError("cant serialize json")  }
        
        
        
        return jsonObj
        
    }
    
    override func setUp() {
        MyraTests.faker = Faker(locale: "en-CA")
    }
    
    func test_Can_Create_Valid_Mock_Agreement() {
        guard let jsonObj = MyraTests.helper_readJSONFromFile(fileName: "Static Test Data\\AgreementData.json") else {
            fatalError("unable to load json")
        }
        
        var agreement = Agreement(json: jsonObj)
        XCTAssert(false)
    }
    
    func test_Can_Create_RUP_From_Mock_Agreement() {
        XCTAssert(false)
    }
    
    func test_Can_Set_RUP_Start_Date_Past_Agreement_End_Date() {
        XCTAssert(false)
    }
    
    func test_Can_Set_RUP_End_Date_Past_Agreement_End_Date() {
        XCTAssert(false)
    }
    
    func test_Can_Create_Usage_data_extending_past_agreement_to_RUP_end_date()
    {
        XCTAssert(false)
    }
    
    func test_Can_Identify_date_in_usage_period_as_FTA_set_or_Extended()
    {
        XCTAssert(false)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    

}

//
//  MyraTests.swift
//  MyraTests
//
//  Created by Wells, Micheal W IIT:EX on 2019-09-16.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import XCTest
import Fakery



class MyraTests: XCTestCase {
   
    static var faker = Faker()
    
    override func setUp() {
        MyraTests.faker = Faker(locale: "en-CA")
    }
    
    func test_Can_Create_Valid_Mock_Agreement() {
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

//
//  FileToJson.swift
//  MyraTests
//
//  Created by Wells, Micheal W IIT:EX on 2019-10-04.
//  Copyright © 2019 Government of British Columbia. All rights reserved.
//

import Foundation
import SwiftyJSON

 func searchBundlesForPath(fileName: String, fileExtension: String) -> String
{
    var pathString:String = ""
    for aBundle in Bundle.allBundles
    {
        pathString = aBundle.path(forResource: fileName, ofType: fileExtension) ?? pathString
        
        if pathString != "" {
            return pathString
        }
    }
    return ""
}

 func helper_readJSONFromFile(fileName: String, fileExtension: String) -> JSON?
{
    
    let pathString = MyraTests.searchBundlesForPath(fileName: fileName, fileExtension: fileExtension)
    
    guard let jsonString = try? NSString(contentsOfFile: pathString, encoding: String.Encoding.utf8.rawValue) as String else {
        fatalError("Unable to convert " + fileName + " to String")
    }
    
    guard let jsonData = jsonString.data(using: .utf8) else {
        fatalError("cant serialize json")
    }
    
    guard let jsonObj = try? JSON(data: jsonData) else {fatalError("cant serialize json")  }
    
    
    
    return jsonObj
    
}


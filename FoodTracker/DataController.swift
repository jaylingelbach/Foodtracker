//
//  DataController.swift
//  FoodTracker
//
//  Created by Jay Lingelbach on 9/29/15.
//  Copyright (c) 2015 Jay Lingelbach. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataController {
    
    // pass in a dictionary and return an array of tuples
    class func jsonAsUSDAIdAndNameSearchResults (json : NSDictionary) -> [(name: String, idValue: String)] {
        
        // array to add tuples to
        var usdaItemsSearchResults: [(name: String, idValue: String)] = []

        var searchResult: (name:String, idValue: String)
        
        // index into array
        if json["hits"] != nil {
            // Hits is an array of dictionaries
            // instead of detailing every dictionary we use any object
            let results: [AnyObject] = json["hits"]! as! [AnyObject]
            
            //start iterating over the array
            for itemDictionary in results {
                if itemDictionary["_id"] != nil {
                    if itemDictionary["fields"] != nil {
                        let fieldsDictionary = itemDictionary["fields"] as! NSDictionary
                        if fieldsDictionary["item_name"] != nil {
                            let idValue:String = itemDictionary["_id"]! as! String
                            let name: String = itemDictionary["item_name"]! as! String
                            searchResult = (name: name, idValue: idValue)
                            usdaItemsSearchResults += [searchResult]
                        }
                    }
                }
            }
            
        }
        return usdaItemsSearchResults
    }
}
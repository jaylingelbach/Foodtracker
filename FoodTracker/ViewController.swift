//
//  ViewController.swift
//  FoodTracker
//
//  Created by Jay Lingelbach on 9/28/15.
//  Copyright (c) 2015 Jay Lingelbach. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    
    let kAppId = "e09e9b49"
    let kAppKey = "15f3b9851b015fe0ed158f94ad00af69"
    
    var searchController: UISearchController!
    var suggestedSearchFoods: [String] = []
    var filteredSuggestedSearchFoods: [String] = []
    var scopeButtonTitles = ["Reccomended", "Search Results", "Save"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // nil to use the same tableView not a new TVC
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        //setup search bar- Puts bar in cgrect we create
        self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0)
        
        //update tableView Header  with new search bar
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        // searchbar titles
        self.searchController.searchBar.scopeButtonTitles = scopeButtonTitles
        
        //set the search controller delegate = self, which allows us to get access to callbacks that occur in the search bar
        self.searchController.searchBar.delegate = self
        
        //set the presentation context to true, which will ensure the search results controller is presented inside the view controller
        self.definesPresentationContext = true
        
        self.suggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "carrots", "cheddar cheese", "chicken breast", "chili with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // !!!!! ----- UITableViewDataSource ----- !!!!!
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        var foodName: String
        if self.searchController.active {
            foodName = filteredSuggestedSearchFoods[indexPath.row]
        } else {
            foodName = suggestedSearchFoods[indexPath.row]
        }
        
        cell.textLabel?.text = foodName
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if currently searching use filteredSuggested else suggested. Dynamically alter numOfRows
        if self.searchController.active == true {
            return self.filteredSuggestedSearchFoods.count
        } else {
            return self.suggestedSearchFoods.count
        }
    }

    // UISearchResultsUpdating
        func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = self.searchController.searchBar.text
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        self.filterContentForSearch(searchString, scope: selectedScopeButtonIndex)
        self.tableView.reloadData()
        
        
    }
    
    // UISearchBarDelegate
    //implement a function that will call our request for data once we hit the search button.
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        makeRequest(searchBar.text)
    }
    
    
        func filterContentForSearch (searchText: String, scope: Int) {
        self.filteredSuggestedSearchFoods = self.suggestedSearchFoods.filter({ (food : String) -> Bool in
            var foodMatch = food.rangeOfString(searchText)
            return foodMatch != nil
        })
    }
    
    // !!!!! ----- API Request ----- !!!!!
    
    func makeRequest(searchString: String) {
// HOW TO MAKE HTTP GET REQUEST!!!
        
//        let url = NSURL(string: "https://api.nutritionix.com/v1_1/search/\(searchString))?results=0%3A20&cal_min=0&cal_max=50000&fields=item_name%2Cbrand_name%2Citem_id%2Cbrand_id&appId= \(kAppId)&appKey=\(kAppKey)")
//        // NSURLSession lets us connect to an API
//        // data task with url creates the get request
//        // completion handler when the request is complete
//        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
//            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
//            println(stringData)
//            println(response)
//        })
//        //executes request
//        task.resume()
        
        // basic url string for http post request
        //mutable to make changes later on
        var request = NSMutableURLRequest(URL: NSURL(string: "https://api.nutritionix.com/v1_1/search/")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        // key value pairs (Dictionary)
        var params = [
            "appId" : kAppId,
            "appKey" : kAppKey,
            "fields" : ["item_name", "brand_name", "keywords", "usda_fields"],
            "limit"  : "50",
            "query"  : searchString,
            
            //exists and its value is another dictionary
            "filters": ["exists":["usda_fields": true]]]
        
        var error: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // create a NSURLSessionDataTask, which will allow us to create our HTTP request using a URL and call a completion handler when this is completed.
        //first step create a var passing our request
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println(stringData)
            // create a dictionary using NSDictionary - much cleaner to read than just the string data!
            var conversionError: NSError?
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &conversionError) as? NSDictionary
            println(jsonDictionary)
        })
        
        task.resume()
        
    }
    

    
// EOF
}


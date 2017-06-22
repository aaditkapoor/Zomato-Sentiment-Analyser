//
//  SearchViewController.swift
//  ZomatoAnalyser
//
//  Created by Aadit Kapoor on 6/17/17.
//  Copyright © 2017 Aadit Kapoor. All rights reserved.
//

import UIKit
import Networking
import Foundation
import Alamofire
import SwiftSpinner

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    var reviews:[String] = []
    
    
    
  var positives = 0
 var negatives = 0
    
    var searchList:[String] = []
    
    
    var resData:Dictionary<String,String> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            let networking = Networking(baseURL: create_search_url(q: searchText)!)
            networking.headerFields = ["user-key": "dc8442573c7f7f06411cc5c93be0465e"]
            
            networking.get("/get") { result in
                switch(result) {
                case .success(let response):
                    let json = response.dictionaryBody
                    // Init the table view
                    
                    var data = json["restaurants"] as! NSArray
                    for e in data {
                        let dx = e as! NSDictionary
                        var toget = (dx.value(forKey: "restaurant")) as! NSDictionary
                        var n = toget.value(forKey: "name")! // Res Name
                        var a = toget.value(forKey: "location")! as! NSDictionary // Res Location
                        let tofeed = String(describing: n) + ":" + String(describing: a.value(forKey: "address")!)
                        
                        print (tofeed)
                        
                        var R = toget.value(forKey: "R") as! NSDictionary
                        
                        self.resData[tofeed] = String(describing: R.value(forKey: "res_id")!)
                        
                        
                        self.searchList.append(tofeed)
                        self.searchList.reverse()
                        self.tableView.reloadData()
                        
                    }
                    
                case .failure(let response):
                    print ("Failure")
                }
            }
            
            
        }
        else {
            self.searchList = []
            self.resData = [:]
            self.tableView.reloadData()
            print ("textfield is empty")
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Adding search functionality
        searchBar.resignFirstResponder()
        
        if searchList.contains(searchBar.text!) {
            for i in searchList {
                // swap elements
            }
        }
        
    }
    
    func createReviewAlert(message: String) {
        // Sentiment Analysis report
    }
    
    
    func makeAnalysisReport(reviews:[String]) {
        
        let queue = DispatchQueue(label: "REVIEWS")
        
        
        for r in reviews {
            queue.async {
                
                Alamofire.request("https://zomatosentimental.herokuapp.com/check/?review=\(r)").responseJSON { (response) in
                    
                    if response.result.value != nil {
                        let json = response.result.value as! Dictionary<String,String>
                        let result = json["result"]
                        print(result)
                    }
                    
                    
                }
                
                
            }
        }
        
    }
    
    var total_data:String = ""
    var pos:[Bool] = []
    var neg:[Bool] = []
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selected = tableView.cellForRow(at: indexPath)
        let resID_ = self.resData[(selected?.textLabel?.text)!] // resID
        
        let networking = Networking(baseURL: create_review_url(resID: resID_!))
        networking.headerFields = ["user-key": "dc8442573c7f7f06411cc5c93be0465e"]
        
        var pos_list = 0
        var neg_list = 0
        networking.get("/get") { result in
            switch(result) {
            case .success(let response):
                let json = response.dictionaryBody
                var reviews:[String] = []
                
                
                var data = json["user_reviews"] as! NSArray
                for e in data {
                    let dx = e as! NSDictionary
                    var toget = (dx.value(forKey: "review")) as! NSDictionary
                    for review in toget {
                        if review.key as! String == "review_text"
                            
                        
                        {
                          
                           var c = review.value as! String
                            c = c.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

                            self.createRequest(review: c, done: self.done)
                            
                            
                        
                        }
                        
                        
                    }

                    
                    
                    
                }
                
                
                

                
                
            case .failure(let response):
                self.createAlert(message:"There was an unexpected error.")
                break
                
                
            }
        }
        
        
        print("Postivies: \(positives)")
        print("Negatives: \(negatives)")
        
        
        
        check()
        
        
        
        
        
    }
    
    
    func check() {
        self.dismiss(animated: true, completion: nil)
        if self.positives == self.negatives {
            self.createAlert(message: "Can't say about this restaurant!")
            self.positives = 0
            self.negatives = 0
            
        }
        else if self.positives > self.negatives {
            self.createAlert(message: "All set! This is the place to go.")
            self.positives = 0
            self.negatives = 0
        }
        else {
            self.createAlert(message: "Not Good!")
            self.positives = 0
            self.negatives = 0
        }
    }
    
    func createRequest(review:String,done:@escaping (Bool)->Void) -> Bool {
        var d = review.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        var flag = false
        Alamofire.request("https://zomatosentimental.herokuapp.com/check/?review=\(d!)").responseJSON { (response) in
            
            if response.result.value != nil {
                let json = response.result.value as! NSDictionary
                let r = json.object(forKey: "result") as! Bool
                
                done(r)
            }
            else {
                print("Error")
                
            }
            
            
        }
        
        if flag {
            return true
        }
        else {
            return false
        }
        
        
    }
    
    func done(r:Bool) {
        if r {
            self.positives+=1
            
        }
        else {
            self.negatives+=1
        }
    }
    
    
    
    func createAlert(message:String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let ac = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ac)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = self.searchList[indexPath.row]
        cell.textLabel?.sizeToFit()
        
        return cell
    }
    
    
    
    
    
    
    
}

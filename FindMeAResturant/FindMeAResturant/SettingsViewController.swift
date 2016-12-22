//
//  SettingsViewController.swift
//  FindMeAResturant
//
//  Created by Kasra Sheik on 11/13/16.
//  Copyright © 2016 Kasra Sheik. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet var searchMiles: UILabel!
    @IBOutlet var searchDistanceSlider: UISlider!
    
    @IBOutlet var minimumRatingControl: UISegmentedControl!
    
    @IBOutlet var selectedKeyword: UILabel!
    
    @IBOutlet var priceRange: UISegmentedControl!
    var meters = 0
    
    
    @IBOutlet var keywordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        
        
        let defaults = UserDefaults.standard
        let decodedData = defaults.object(forKey: "userPreferences") as! NSData
        var userPreferences = NSKeyedUnarchiver.unarchiveObject(with: decodedData as Data) as! [String]
        
        self.searchDistanceSlider.value = Float(userPreferences[0])!
        self.searchMiles.text = userPreferences[0] + " meters"
        self.meters = Int(userPreferences[0])!
        self.minimumRatingControl.selectedSegmentIndex = Int(userPreferences[1])!
        var priceRange = 0
        if(userPreferences[2] == "low") {
            priceRange = 0
        }
        else {
            priceRange = 1
        }
        self.priceRange.selectedSegmentIndex = priceRange
        self.selectedKeyword.text = userPreferences[3]
        self.keywordTextField.text = userPreferences[3]
        
        
        
        
        //set default values for miles for now ...

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchDistanceSlider(_ sender: AnyObject) {
        
        
        self.meters = Int(self.searchDistanceSlider.value)

        let currentMiles = String(Int(self.meters)) + " meters"
        
        self.searchMiles.text = currentMiles
        
        
        
    }
    @IBAction func saveSettings(_ sender: AnyObject) {
        
        //present alert
        if(self.meters == 0) {
            let alert = UIAlertController(title: "Cannot find restaurants in this search distance", message: "increase your search preferences", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
            
        }
        
        print("saving settings...")
        
        let defaults = UserDefaults.standard
        let decodedData = defaults.object(forKey: "userPreferences") as! NSData
        var userPreferences = NSKeyedUnarchiver.unarchiveObject(with: decodedData as Data) as! [String]
        
        userPreferences[0] = String(self.meters)
        userPreferences[1] = String(self.minimumRatingControl.selectedSegmentIndex)
        
        if(self.priceRange.selectedSegmentIndex == 0) {
            userPreferences[2] = "low"
        }
        else {
            userPreferences[2] = "high"
        }
        
        userPreferences[3] = self.keywordTextField.text!
        self.selectedKeyword.text = userPreferences[3]
        
        //save settings in defaults
        
        
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: userPreferences)
        defaults.set(encodedData, forKey: "userPreferences")
        defaults.synchronize()
        
        let alert = UIAlertController(title: "Saved!", message: "your preferneces are saved, feel free to change them at any time.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)

       
        
        
        
        
    }

   
}

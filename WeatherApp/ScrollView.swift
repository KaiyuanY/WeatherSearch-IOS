//
//  ScrollView.swift
//  WeatherApp
//
//  Created by Kaiyuan Yu on 12/9/21.
//

import UIKit

@objc protocol ScrollViewValueChangedDelegate{
    func pageRemoved(childView: ScrollView)
}
class ScrollView: UIView {
    var delegate:ScrollViewValueChangedDelegate?
    var weatherData:WeatherDataModel?
    @IBOutlet weak var deleteButton: UIButton!
    //card1
    @IBOutlet weak var card1View: UIView!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherTextLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    //card2
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    //card3
    @IBOutlet weak var weeklyWeatherTable: UITableView!
    

    @IBAction func deleteButtonPressed(_ sender: Any) {
        //self.removeFromSuperview()
        print("delete button pressed")
        let userDefaults = UserDefaults.standard
        var favorites = WeatherDataModel.jsonToObj(json: (userDefaults.string(forKey: "favorites")!))
        for index in 0..<favorites.count{
            if favorites[index].city! == weatherData?.city{
                favorites.remove(at: index)
                break
            }
        }
        let jsonString = WeatherDataModel.objToJson(obj: favorites)
        //print("json string = \(jsonString)")
        userDefaults.set(jsonString, forKey: "favorites")
        print("delegate == nil? \(self.delegate == nil)")
        self.delegate?.pageRemoved(childView: self)
        
    }
    
    
}

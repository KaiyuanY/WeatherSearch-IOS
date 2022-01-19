//
//  TabBarViewController.swift
//  WeatherApp
//
//  Created by Kaiyuan Yu on 12/8/21.
//

import UIKit

class TabBarViewController: UITabBarController,UINavigationControllerDelegate {
    var city = ""
    var weatherData:WeatherDataModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.delegate = self
        // Do any additional setup after loading the view.
        navigationItem.title = city
    }
    
    @IBAction func twitterbuttonPressed(_ sender: Any) {
        let application = UIApplication.shared
        let urlString = "https://twitter.com/intent/tweet?text="
        var contentString = "The temperature in \(city) is \((weatherData?.currentWeatherData.temperature)!)F. The weather conditions are \(WeatherDataModel.getTextFromWeatherCode(code: (weatherData?.currentWeatherData.weatherCode)!)) #CSCI571WeatherSearch"
        contentString = contentString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        print("content string = " + contentString)
        let url = URL(string: urlString + contentString)
        application.open(url!)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

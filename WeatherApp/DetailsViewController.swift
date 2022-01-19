//
//  DetailsViewController.swift
//  WeatherApp
//
//  Created by Kaiyuan Yu on 12/8/21.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    @IBOutlet weak var uvIndexLabel: UILabel!
    
    @IBOutlet weak var bgView1: UIView!
    @IBOutlet weak var bgView2: UIView!
    @IBOutlet weak var bgView3: UIView!
    @IBOutlet weak var bgView4: UIView!
    @IBOutlet weak var bgView5: UIView!
    @IBOutlet weak var bgView6: UIView!
    @IBOutlet weak var bgView7: UIView!
    @IBOutlet weak var bgView8: UIView!
    @IBOutlet weak var bgView9: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var bgViewArray:[UIView] = []
        bgViewArray.append(bgView1)
        bgViewArray.append(bgView2)
        bgViewArray.append(bgView3)
        bgViewArray.append(bgView4)
        bgViewArray.append(bgView5)
        bgViewArray.append(bgView6)
        bgViewArray.append(bgView7)
        bgViewArray.append(bgView8)
        bgViewArray.append(bgView9)
        for bgView in bgViewArray{
            bgView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            bgView.layer.cornerRadius = 5
            bgView.layer.borderWidth = 1
            bgView.layer.borderColor = UIColor.white.cgColor
        }
        
        
        
        let tabbar = tabBarController as! TabBarViewController
        let weatherData = (tabbar.weatherData?.currentWeatherData)!
        // Do any additional setup after loading the view.
        windSpeedLabel.text = "\((weatherData.windSpeed)) mph"
        pressureLabel.text = "\(weatherData.pressure) inHg"
        precipitationLabel.text = "\(weatherData.precipitation)%"
        temperatureLabel.text = "\(weatherData.temperature)°F"
        let weather = WeatherDataModel.getTextFromWeatherCode(code: weatherData.weatherCode)
        weatherLabel.text = weather
        print("weather = \(weather)")
        let image = UIImage(named: weather)
        weatherImage.image = image
        humidityLabel.text = "\(weatherData.humidity)%"
        visibilityLabel.text = "\(weatherData.visibility) mi"
        cloudCoverLabel.text = "\(weatherData.cloudCover)%"
        uvIndexLabel.text = "\(weatherData.uvIndex)"
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

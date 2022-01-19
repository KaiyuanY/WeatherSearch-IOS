//
//  SearchResultViewController.swift
//  WeatherApp
//
//  Created by Kaiyuan Yu on 12/7/21.
//

import UIKit
import SwiftSpinner
import Alamofire
import SwiftyJSON
import CoreLocation
import Toast
import OrderedCollections

protocol DetailViewValueChangedDelegate{
    func pageRemoved(city: String)
    func pageAdded(data: WeatherDataModel)
}

class SearchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate {
    
    var localWeather:WeatherDataModel?
    var currentCity: String?
    
    var plusButtonImage = UIImage(named: "plus-circle")
    var closeButtonImage = UIImage(named: "close-circle")
    var isSaved = false
    
    var userDefaults = UserDefaults.standard
    var delegate:DetailViewValueChangedDelegate?
    
    //card1
    @IBOutlet weak var card1View: UIView!
    @IBOutlet weak var favBotton: UIButton!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherTextLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var detailsButton: UIButton!
    //card2
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    //card3
    @IBOutlet weak var weeklyWeatherTable: UITableView!
    
    override func viewDidLoad() {
        
        self.navigationController?.delegate = self
        
        
        card1View.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        card1View.layer.cornerRadius = 10
        card1View.layer.borderWidth = 1
        card1View.layer.borderColor = UIColor.white.cgColor
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(card1ViewPressed(sender:)))
        card1View.addGestureRecognizer(gesture)
        
        weeklyWeatherTable.register(UINib(nibName: "WeeklyTableViewCell", bundle: nil), forCellReuseIdentifier: "WeeklyTableViewCell")
        weeklyWeatherTable.delegate = self
        weeklyWeatherTable.dataSource = self
        weeklyWeatherTable.layer.cornerRadius = 10
        
        navigationItem.title = currentCity
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.currentCity!) {
            placemarks, error in
            print("getting lat lon")
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            print("Lat: \(lat), Lon: \(lon)")
            DataService.getWeatherDataFromBackend(lat: lat ?? 34.052235, lon: lon ?? -118.243683, callback: self.setupInitialView)
            print("after data service")
            SwiftSpinner.show("Fetching Weather")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        //self.setupInitialView(data: localWeather!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyTableViewCell", for: indexPath) as! WeeklyTableViewCell
        if localWeather != nil{
            let weeklyData = (localWeather?.weeklyWeatherData)!
            let date = WeatherDataModel.toDateString(date: weeklyData[indexPath.row].date)
            let image = WeatherDataModel.getTextFromWeatherCode(code: weeklyData[indexPath.row].weatherCode)
            let sunrise = WeatherDataModel.toTimeString(date: weeklyData[indexPath.row].sunrise!)
            let sunset = WeatherDataModel.toTimeString(date: weeklyData[indexPath.row].sunset!)
            cell.configureCell(date: date, imageName: image, sunrise: sunrise, sunset: sunset)
        }
        
        return cell
    }
    
    func setupInitialView(data:WeatherDataModel){
        //check if this city is already in favorite list, and accordingly set the favorite button
        let favorites = WeatherDataModel.jsonToObj(json: (userDefaults.string(forKey: "favorites")!))
        for index in 0..<favorites.count{
            if favorites[index].city! == currentCity{
                isSaved = true
            }
        }
        if isSaved {
            self.favBotton.setImage(self.closeButtonImage, for: .normal)
        }
        else{
            self.favBotton.setImage(self.plusButtonImage, for: .normal)
        }
        
        self.localWeather = data
        localWeather?.city = currentCity
//        print("-----searched-Weather-----\n")
//        dump(self.localWeather)
//        print("weather code = \(localWeather!.currentWeatherData.weatherCode)")
//        print("weather image = \(WeatherDataModel.getTextFromWeatherCode(code: (localWeather?.currentWeatherData.weatherCode)!))")
        
        let weatherImage = UIImage(named: WeatherDataModel.getTextFromWeatherCode(code: (localWeather?.currentWeatherData.weatherCode)!))
        currentWeatherImage.image = weatherImage
        weatherTextLabel.text = WeatherDataModel.getTextFromWeatherCode(code: (localWeather?.currentWeatherData.weatherCode)!)
        cityLabel.text = currentCity!
        temperatureLabel.text = "\((localWeather?.currentWeatherData.temperature)!)\u{00B0}F"
        
        humidityLabel.text = "\((localWeather?.currentWeatherData.humidity)!) %"
        windSpeedLabel.text = "\((localWeather?.currentWeatherData.windSpeed)!) mph"
        visibilityLabel.text = "\((localWeather?.currentWeatherData.visibility)!) mi"
        pressureLabel.text = "\((localWeather?.currentWeatherData.pressure)!) inHg"
        
        weeklyWeatherTable.reloadData()
        
        SwiftSpinner.hide()
    }
    
    //open a web browser to make a twit
    @IBAction func twitterButtonPressed(_ sender: Any) {
        let application = UIApplication.shared
        let urlString = "https://twitter.com/intent/tweet?text="
        var contentString = "The temperature in \(currentCity!) is \((localWeather?.currentWeatherData.temperature)!)F. The weather conditions are \(WeatherDataModel.getTextFromWeatherCode(code: (localWeather?.currentWeatherData.weatherCode)!)) #CSCI571WeatherSearch"
        contentString = contentString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        print("content string = " + contentString)
        let url = URL(string: urlString + contentString)
        application.open(url!)
    }
    
    // save/unsave the current city along with its weather data
    @IBAction func favButtonPressed(_ sender: Any) {
        var favorites = WeatherDataModel.jsonToObj(json: (userDefaults.string(forKey: "favorites")!))
        if(isSaved){//unsave the current location
            self.favBotton.setImage(self.plusButtonImage, for: .normal)
            
            for index in 0..<favorites.count{
                if favorites[index].city! == currentCity{
                    favorites.remove(at: index)
                    break
                }
            }
            
            self.view.makeToast("\(currentCity!) was removed the Favorite List", duration: 2.0, position: .bottom)
            print("weather deleted")
        }
        else{//save the current location
            self.favBotton.setImage(self.closeButtonImage, for: .normal)
            
            favorites.append(self.localWeather!)
            self.view.makeToast("\(currentCity!) was saved to the Favorite List", duration: 2.0, position: .bottom)
            print("weather saved")
        }
        let jsonString = WeatherDataModel.objToJson(obj: favorites)
        //print("json string = \(jsonString)")
        userDefaults.set(jsonString, forKey: "favorites")
        isSaved = !isSaved
    }
    
    @IBAction func detailsButtonPressed(_ sender: UIButton) {
        print("details button pressed")
        performSegue(withIdentifier: "ShowTabView", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! TabBarViewController
        vc.city = self.currentCity!
        vc.weatherData = self.localWeather
    }
    @objc func card1ViewPressed(sender : UITapGestureRecognizer) {
        print("detail button pressed...")
        performSegue(withIdentifier: "ShowTabView", sender: self)
    }
    
}

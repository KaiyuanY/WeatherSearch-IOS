//
//  ViewController.swift
//  WeatherApp
//
//  Created by Kaiyuan Yu on 12/3/21.
//

import UIKit
import CoreLocation
import SwiftyJSON
import Alamofire
import SwiftSpinner
import Toast
import OrderedCollections

class HomePageViewController: UIViewController, CLLocationManagerDelegate,UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, ScrollViewValueChangedDelegate, DetailViewValueChangedDelegate {

    var userDefaults = UserDefaults.standard
    
    var locationManager: CLLocationManager?
    var localWeather:WeatherDataModel?
    var currentCity: String?
    var autoCompleteCityList:[String] = []
    var searchText = ""
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var autoCompleteTable: UITableView!
    
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
    
    //page controll
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    var scrollViewPages:[ScrollView] = []
    var weatherDataArray:[WeatherDataModel] = []
    
    var firstTimeAppearing = true
    
    override func viewWillAppear(_ animated: Bool) {
        print("-----ViewWilAppear-----")
        if firstTimeAppearing{
            return
        }
        //back from the detail view
        let json = userDefaults.string(forKey: "favorites")!
        let favorites = WeatherDataModel.jsonToObj(json: json)
        for savedData in favorites{
            print("before add/delete. saved city: \(savedData.city)")
        }
        for savedData in weatherDataArray{
            print("before add/delete. whole data city: \(savedData.city)")
        }
        if favorites.count == weatherDataArray.count{
            //added
            print("add detected")
            let data = favorites[favorites.count-1]
            let curScrollView = Bundle.main.loadNibNamed("ScrollView", owner: self, options: nil)?.first as! ScrollView
            curScrollView.delegate = self
            curScrollView.weatherData = data
            let weatherImage = UIImage(named: WeatherDataModel.getTextFromWeatherCode(code: (data.currentWeatherData.weatherCode)))
            curScrollView.currentWeatherImage.image = weatherImage
            curScrollView.weatherTextLabel.text = WeatherDataModel.getTextFromWeatherCode(code: (data.currentWeatherData.weatherCode))
            curScrollView.cityLabel.text = data.city!
            curScrollView.temperatureLabel.text =  "\((data.currentWeatherData.temperature))\u{00B0}F"
            
            curScrollView.humidityLabel.text = "\((data.currentWeatherData.humidity)) %"
            curScrollView.windSpeedLabel.text = "\((data.currentWeatherData.windSpeed)) mph"
            curScrollView.visibilityLabel.text = "\((data.currentWeatherData.visibility)) mi"
            curScrollView.pressureLabel.text = "\((data.currentWeatherData.pressure)) inHg"
            curScrollView.card1View.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            curScrollView.card1View.layer.cornerRadius = 10
            curScrollView.card1View.layer.borderWidth = 1
            curScrollView.card1View.layer.borderColor = UIColor.white.cgColor
            
            curScrollView.weeklyWeatherTable.register(UINib(nibName: "WeeklyTableViewCell", bundle: nil), forCellReuseIdentifier: "WeeklyTableViewCell")
            curScrollView.weeklyWeatherTable.delegate = self
            curScrollView.weeklyWeatherTable.dataSource = self
            curScrollView.weeklyWeatherTable.layer.cornerRadius = 10
            curScrollView.weeklyWeatherTable.reloadData()
            scrollViewPages.append(curScrollView)
            weatherDataArray.append(data)
            pageControl.numberOfPages = weatherDataArray.count
            for index in 0..<scrollViewPages.count{
                scrollViewPages[index].frame = CGRect(x: scrollView.frame.size.width * CGFloat(index), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            }
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(scrollViewPages.count), height: scrollView.frame.size.height)
            scrollView.addSubview(curScrollView)
            view.bringSubviewToFront(pageControl)
            for savedData in favorites{
                print("after add. saved city: \(savedData.city)")
            }
            for savedData in weatherDataArray{
                print("after add. whole data city: \(savedData.city)")
            }
        }
        else if favorites.count == weatherDataArray.count-2{
            //deleted
            print("delete detected")
            for var index in 0..<favorites.count{
                print("favorite at index \(index) = \(favorites[index].city)")
                print("olddata at index+1 \(index+1) = \(weatherDataArray[index].city)")
                if favorites[index].city != weatherDataArray[index+1].city {
                    index += 1
                    print("found the exact scroll view to delete")
                    print("delete index = \(index)")
                    scrollViewPages[index].removeFromSuperview()
                    scrollViewPages.remove(at: index)
                    weatherDataArray.remove(at: index)
                    print("array size after deletion = \(weatherDataArray.count)")
                    pageControl.numberOfPages = scrollViewPages.count
                    //pageControl.currentPage = index - 1
                    for index1 in 0..<scrollViewPages.count{
                        scrollViewPages[index1].frame = CGRect(x: scrollView.frame.size.width * CGFloat(index1), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                    }
//                    scrollView.setContentOffset(CGPoint(x: CGFloat(CGFloat((index-1))*scrollView.frame.size.width), y: 0), animated: true)
                    scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(scrollViewPages.count), height: scrollView.frame.size.height)
                    view.bringSubviewToFront(pageControl)
                }
                else if index == favorites.count-1 && favorites[index].city == weatherDataArray[index+1].city{
                    index = weatherDataArray.count-1
                    scrollViewPages[index].removeFromSuperview()
                    scrollViewPages.remove(at: index)
                    weatherDataArray.remove(at: index)
                    print("array size after deletion = \(weatherDataArray.count)")
                    pageControl.numberOfPages = scrollViewPages.count
                    //pageControl.currentPage = index - 1
                    for index1 in 0..<scrollViewPages.count{
                        scrollViewPages[index1].frame = CGRect(x: scrollView.frame.size.width * CGFloat(index1), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                    }
//                    scrollView.setContentOffset(CGPoint(x: CGFloat(CGFloat((index-1))*scrollView.frame.size.width), y: 0), animated: true)
                    scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(scrollViewPages.count), height: scrollView.frame.size.height)
                    view.bringSubviewToFront(pageControl)
                }
            }
            for savedData in favorites{
                print("after add. saved city: \(savedData.city)")
            }
            for savedData in weatherDataArray{
                print("after add. whole data city: \(savedData.city)")
            }
        }
        else{// favorites.count == weatherDataArray.count-1
            //nothing changed
            print("unchanged detected")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //userDefaults.removeObject(forKey: "favorites")
        
        
        let json = userDefaults.string(forKey: "favorites")
        if json == nil{
            let dummyArray:[WeatherDataModel] = []
            let json = WeatherDataModel.objToJson(obj: dummyArray)
            userDefaults.set(json, forKey: "favorites")
        }
        
        searchBar.delegate = self
        navBar.titleView = searchBar

        autoCompleteTable.dataSource = self
        autoCompleteTable.delegate = self
        autoCompleteTable.isHidden = true
        
        self.navigationController?.delegate = self
        scrollView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
    }
    
    
    /***********************************
     *           location service                       *
     ******************************************************/
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager?.requestLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            print("locations = \(locValue.latitude) \(locValue.longitude)")
        print("location getting data")
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {
            (placemarks, error) in
            if error == nil{
                self.currentCity = placemarks?.first?.locality
            }
        })
        DataService.getWeatherDataFromBackend(lat: locValue.latitude, lon: locValue.longitude, callback: setupInitialView)
        SwiftSpinner.show("Loading Weather Data")
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("error:: \(error.localizedDescription)")
    }
    /***********************************
     *           Initial View Setup                    *
     ******************************************************/
    func setupInitialView(data:WeatherDataModel){
        self.localWeather = data
        data.city = currentCity
        weatherDataArray.append(data)
        let json = userDefaults.string(forKey: "favorites")!
        let favorites = WeatherDataModel.jsonToObj(json: json)
        
        for savedData in favorites{
            print("saved city: \(savedData.city)")
            weatherDataArray.append(savedData)
        }
        print("set up initial view called, weatherDataArray.length = \(weatherDataArray.count)")
        for index in 0..<weatherDataArray.count{
            let curScrollView = Bundle.main.loadNibNamed("ScrollView", owner: self, options: nil)?.first as! ScrollView
            if index == 0{
                curScrollView.deleteButton.isHidden = true
                let gesture = UITapGestureRecognizer(target: self, action:  #selector(card1ViewPressed(sender:)))
                curScrollView.card1View.addGestureRecognizer(gesture)
            }
            curScrollView.delegate = self
            curScrollView.weatherData = weatherDataArray[index]
            let weatherImage = UIImage(named: WeatherDataModel.getTextFromWeatherCode(code: (weatherDataArray[index].currentWeatherData.weatherCode)))
            curScrollView.currentWeatherImage.image = weatherImage
            curScrollView.weatherTextLabel.text = WeatherDataModel.getTextFromWeatherCode(code: (weatherDataArray[index].currentWeatherData.weatherCode))
            curScrollView.cityLabel.text = weatherDataArray[index].city!
            curScrollView.temperatureLabel.text =  "\((weatherDataArray[index].currentWeatherData.temperature))\u{00B0}F"
            
            curScrollView.humidityLabel.text = "\((weatherDataArray[index].currentWeatherData.humidity)) %"
            curScrollView.windSpeedLabel.text = "\((weatherDataArray[index].currentWeatherData.windSpeed)) mph"
            curScrollView.visibilityLabel.text = "\((weatherDataArray[index].currentWeatherData.visibility)) mi"
            curScrollView.pressureLabel.text = "\((weatherDataArray[index].currentWeatherData.pressure)) inHg"
            curScrollView.card1View.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            curScrollView.card1View.layer.cornerRadius = 10
            curScrollView.card1View.layer.borderWidth = 1
            curScrollView.card1View.layer.borderColor = UIColor.white.cgColor
            
            curScrollView.weeklyWeatherTable.register(UINib(nibName: "WeeklyTableViewCell", bundle: nil), forCellReuseIdentifier: "WeeklyTableViewCell")
            curScrollView.weeklyWeatherTable.delegate = self
            curScrollView.weeklyWeatherTable.dataSource = self
            curScrollView.weeklyWeatherTable.layer.cornerRadius = 10
            curScrollView.weeklyWeatherTable.reloadData()
            scrollViewPages.append(curScrollView)
        }
        view.bringSubviewToFront(pageControl)
        pageControl.addTarget(self, action: #selector(pageControlDidChange(_:)), for: .valueChanged)
        pageControl.numberOfPages = scrollViewPages.count
//        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(scrollViewPages.count), height: scrollView.frame.size.height)
        scrollView.isPagingEnabled = true
        for index in 0..<scrollViewPages.count{
            scrollViewPages[index].frame = CGRect(x: scrollView.frame.size.width * CGFloat(index), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            scrollView.addSubview(scrollViewPages[index])
        }
        print("-----localWeather-----\n")
        //dump(self.localWeather)
//        let weatherImage = UIImage(named: WeatherDataModel.getTextFromWeatherCode(code: (localWeather?.currentWeatherData.weatherCode)!))
//        currentWeatherImage.image = weatherImage
//        weatherTextLabel.text = WeatherDataModel.getTextFromWeatherCode(code: (localWeather?.currentWeatherData.weatherCode)!)
//        cityLabel.text = currentCity!
//        temperatureLabel.text = "\((localWeather?.currentWeatherData.temperature)!)\u{00B0}F"
//
//        humidityLabel.text = "\((localWeather?.currentWeatherData.humidity)!) %"
//        windSpeedLabel.text = "\((localWeather?.currentWeatherData.windSpeed)!) mph"
//        visibilityLabel.text = "\((localWeather?.currentWeatherData.visibility)!) mi"
//        pressureLabel.text = "\((localWeather?.currentWeatherData.pressure)!) inHg"
//
//        weeklyWeatherTable.reloadData()
        
        SwiftSpinner.hide()
        firstTimeAppearing = false
    }
    @objc func pageControlDidChange(_ sender: UIPageControl){
        let current = sender.currentPage
        print("current page = \(current)")
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.width * CGFloat(current), y: 0), animated: true)
//        if current == 0{
//            self.deleteButton.isHidden = true
//        }
//        else{
//            self.deleteButton.isHidden = false
//        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(floorf(Float(scrollView.contentOffset.x)/Float(scrollView.frame.width)))
        let current = pageControl.currentPage
//        if current == 0{
//            self.deleteButton.isHidden = true
//        }
//        else{
//            self.deleteButton.isHidden = false
//        }
    }
    
    
    /***********************************
     *           TableView Handlers                  *
     ******************************************************/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == autoCompleteTable{
            return autoCompleteCityList.count
        }
        else{
            return 7
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == autoCompleteTable{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCompleteCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = autoCompleteCityList[indexPath.row]
            cell.contentConfiguration = content
            
            return cell
        }
        else{
            for page in scrollViewPages{
                if tableView == page.weeklyWeatherTable{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyTableViewCell", for: indexPath) as! WeeklyTableViewCell
                    if page.weatherData != nil{
                        let weeklyData = (page.weatherData?.weeklyWeatherData)!
                        let date = WeatherDataModel.toDateString(date: weeklyData[indexPath.row].date)
                        let image = WeatherDataModel.getTextFromWeatherCode(code: weeklyData[indexPath.row].weatherCode)
                        let sunrise = WeatherDataModel.toTimeString(date: weeklyData[indexPath.row].sunrise!)
                        let sunset = WeatherDataModel.toTimeString(date: weeklyData[indexPath.row].sunset!)
                        cell.configureCell(date: date, imageName: image, sunrise: sunrise, sunset: sunset)
                    }
                    return cell
                }
            }
//            let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyTableViewCell", for: indexPath) as! WeeklyTableViewCell
//            if localWeather != nil{
//                let weeklyData = (localWeather?.weeklyWeatherData)!
//                let date = WeatherDataModel.toDateString(date: weeklyData[indexPath.row].date)
//                let image = WeatherDataModel.getTextFromWeatherCode(code: weeklyData[indexPath.row].weatherCode)
//                let sunrise = WeatherDataModel.toTimeString(date: weeklyData[indexPath.row].sunrise!)
//                let sunset = WeatherDataModel.toTimeString(date: weeklyData[indexPath.row].sunset!)
//                cell.configureCell(date: date, imageName: image, sunrise: sunrise, sunset: sunset)
//            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyTableViewCell", for: indexPath) as! WeeklyTableViewCell
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == autoCompleteTable {
            // deselect and then segue to detail controller
            print("\(autoCompleteCityList[indexPath.row]) is selected")
            self.searchText = autoCompleteCityList[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.isHidden = true
            
            searchBar.text = autoCompleteCityList[indexPath.row]
            performSegue(withIdentifier: "ShowSearchResult", sender: self)
        } else {
            // deselect other table view cell
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    /***********************************
     *           SearchBar Handlers                  *
     ******************************************************/
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Text entered = \(searchText)")
        if searchText.count >= 3{
            DataService.getSearchSuggestion(text: searchText, callback: autoCompleteCallback)
        }
        else{
            self.autoCompleteTable.isHidden = true
        }
    }
    func autoCompleteCallback(predictions: [String]){
        autoCompleteCityList = predictions
        autoCompleteTable.isHidden = false
        autoCompleteTable.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchCity = searchBar.text
        if searchCity == nil {
            return
        }
        performSegue(withIdentifier: "ShowSearchResult", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SearchResultViewController{
            let vc = segue.destination as! SearchResultViewController
            vc.currentCity = searchText
            vc.delegate = self
            print("searchText = \(searchText)")
        }
        else{//detail VC
            let vc = segue.destination as! TabBarViewController
            let index = pageControl.currentPage
            vc.city = self.weatherDataArray[index].city!
            vc.weatherData = self.weatherDataArray[index]
        }
        let backItem = UIBarButtonItem()
        backItem.title = "Weather"
        navigationItem.backBarButtonItem = backItem
    }
    
    /*
        first view card pressed to go to tab bar views
     */
    @objc func card1ViewPressed(sender : UITapGestureRecognizer) {
        print("detail button pressed...")
        performSegue(withIdentifier: "ShowTabView", sender: self)
    }
    
    /*
        handle adding/removing favorite list
     */
    func pageRemoved(childView: ScrollView) {
        print("remove scroll view gets called")
        print("pages count = \(scrollViewPages.count)")
        for index in 1..<scrollViewPages.count{
            if scrollViewPages[index] == childView{
                print("found the exact scroll view to delete")
                
                scrollViewPages[index].removeFromSuperview()
                self.view.makeToast("\((scrollViewPages[index].weatherData?.city)!) was removed the Favorite List", duration: 2.0, position: .bottom)
                scrollViewPages.remove(at: index)
                weatherDataArray.remove(at: index)
                pageControl.numberOfPages = scrollViewPages.count
                pageControl.currentPage = 0
                for index in 0..<scrollViewPages.count{
                    scrollViewPages[index].frame = CGRect(x: scrollView.frame.size.width * CGFloat(index), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                }
                scrollView.setContentOffset(CGPoint(x: CGFloat(CGFloat((index-1))*scrollView.frame.size.width), y: 0), animated: true)
                scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(scrollViewPages.count), height: scrollView.frame.size.height)
                view.bringSubviewToFront(pageControl)
                
                break
            }
        }
    }
    
    func pageRemoved(city: String) {
        print("details controller pageRemoved gets called")
        for index in 1..<weatherDataArray.count{
            if weatherDataArray[index].city == city{
                print("found the exact scroll view to delete")
                
                scrollViewPages[index].removeFromSuperview()
                scrollViewPages.remove(at: index)
                weatherDataArray.remove(at: index)
                pageControl.numberOfPages = scrollViewPages.count
                pageControl.currentPage = index - 1
                for index in 0..<scrollViewPages.count{
                    scrollViewPages[index].frame = CGRect(x: scrollView.frame.size.width * CGFloat(index), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                }
                scrollView.setContentOffset(CGPoint(x: CGFloat(CGFloat((index-1))*scrollView.frame.size.width), y: 0), animated: true)
                scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(scrollViewPages.count), height: scrollView.frame.size.height)
                view.bringSubviewToFront(pageControl)
                self.view.makeToast("\((scrollViewPages[index].weatherData?.city)!) was removed the Favorite List", duration: 2.0, position: .bottom)
                break
            }
        }
    }
    func pageAdded(data: WeatherDataModel) {
        print("details controller pageAdded gets called")
        let curScrollView = Bundle.main.loadNibNamed("ScrollView", owner: self, options: nil)?.first as! ScrollView
        curScrollView.delegate = self
        curScrollView.weatherData = data
        let weatherImage = UIImage(named: WeatherDataModel.getTextFromWeatherCode(code: (data.currentWeatherData.weatherCode)))
        curScrollView.currentWeatherImage.image = weatherImage
        curScrollView.weatherTextLabel.text = WeatherDataModel.getTextFromWeatherCode(code: (data.currentWeatherData.weatherCode))
        curScrollView.cityLabel.text = data.city!
        curScrollView.temperatureLabel.text =  "\((data.currentWeatherData.temperature))\u{00B0}F"
        
        curScrollView.humidityLabel.text = "\((data.currentWeatherData.humidity)) %"
        curScrollView.windSpeedLabel.text = "\((data.currentWeatherData.windSpeed)) mph"
        curScrollView.visibilityLabel.text = "\((data.currentWeatherData.visibility)) mi"
        curScrollView.pressureLabel.text = "\((data.currentWeatherData.pressure)) inHg"
        curScrollView.card1View.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        curScrollView.card1View.layer.cornerRadius = 10
        curScrollView.card1View.layer.borderWidth = 1
        curScrollView.card1View.layer.borderColor = UIColor.white.cgColor
        
        curScrollView.weeklyWeatherTable.register(UINib(nibName: "WeeklyTableViewCell", bundle: nil), forCellReuseIdentifier: "WeeklyTableViewCell")
        curScrollView.weeklyWeatherTable.delegate = self
        curScrollView.weeklyWeatherTable.dataSource = self
        curScrollView.weeklyWeatherTable.layer.cornerRadius = 10
        curScrollView.weeklyWeatherTable.reloadData()
        scrollViewPages.append(curScrollView)
        weatherDataArray.append(data)
        for index in 0..<scrollViewPages.count{
            scrollViewPages[index].frame = CGRect(x: scrollView.frame.size.width * CGFloat(index), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        }
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(scrollViewPages.count), height: scrollView.frame.size.height)
        scrollView.addSubview(curScrollView)
        view.bringSubviewToFront(pageControl)
    }
}


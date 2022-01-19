//
//  DataService.swift
//  WeatherApp
//
//  Created by Kaiyuan Yu on 12/4/21.
//

import Foundation
import Alamofire
import SwiftyJSON
class DataService {
    static var weatherDataAPI:String = "https://hw8-cs571-2021.wl.r.appspot.com/weather?"
    static var googleGeoCodingApi = "https://maps.googleapis.com/maps/api/geocode/json"
    static var googleApiKey = "AIzaSyDpqQYgsWccorymscyUeIHNdREXA9T_5ts";
    static var googleAutoCompleteApi = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    static func getLocationFromCityName(city:String, callback: (Double, Double) -> ()) {
        let requestUrl = googleGeoCodingApi
        AF.request(requestUrl,
                   method: .get,
                   parameters: [
                    "address": city,
                    "key": googleApiKey
                   ]).validate().responseJSON{
            response in
            switch response.result{
            case .success(let value):
                print("google geo get success")
                let json = JSON(value)
                if !json.isEmpty{
                    
                }
                
            case let .failure(error):
                print(error)
            }
        }
    }
    static func getWeatherDataFromBackend(lat:Double, lon:Double, callback: @escaping (WeatherDataModel) -> () ){
        let requestUrl = weatherDataAPI + "lat=\(lat)&lon=\(lon)"
        AF.request(requestUrl).validate().responseJSON{
            response in
            switch response.result{
            case .success(let value):
                print("backend get success")
                let json = JSON(value)
                if !json.isEmpty {
                    //parsing current weather
                    var dateString = json[0]["startTime"].string ?? "2021-12-04T23:13:00-08:00"
                    let dateFormatter = ISO8601DateFormatter()
                    var date = dateFormatter.date(from: dateString)!
                    var temperature = json[0]["intervals"][0]["values"]["temperature"].double ?? 0.0
                    var temperatureMax = json[0]["intervals"][0]["values"]["temperatureMax"].double ?? 0.0
                    var temperatureMin = json[0]["intervals"][0]["values"]["temperatureMin"].double ?? 0.0
                    var windSpeed = json[0]["intervals"][0]["values"]["windSpeed"].double ?? 0.0
                    var humidity = json[0]["intervals"][0]["values"]["humidity"].double ?? 0.0
                    var pressure = json[0]["intervals"][0]["values"]["pressureSeaLevel"].double ?? 0.0
                    var uvIndex = json[0]["intervals"][0]["values"]["uvIndex"].int ?? 0
                    var weatherCode = json[0]["intervals"][0]["values"]["weatherCode"].int ?? 1000
                    var precipitation = json[0]["intervals"][0]["values"]["precipitationProbability"].int ?? 0
                    var visibility = json[0]["intervals"][0]["values"]["visibility"].double ?? 0.0
                    var cloudCover = json[0]["intervals"][0]["values"]["cloudCover"].double ?? 0.0
                    let current = WeatherData(date: date, temperature: temperature, temperatureMax: temperatureMax, temperatureMin: temperatureMin, weatherCode: weatherCode, windSpeed: windSpeed, pressure: pressure, precipitation: precipitation, humidity: humidity, visibility: visibility, cloudCover: cloudCover, uvIndex: uvIndex)
                    //dump(current)
                    //parsing weekly weather
                    let weeklyJson = json[1]["intervals"]
                    var weeklyWeather:[WeatherData] = []
                    for index in 0...14{
                        dateString = weeklyJson[index]["startTime"].stringValue
                        date = dateFormatter.date(from: dateString)!
                        temperature = weeklyJson[index]["values"]["temperature"].double ?? 0.0
                        temperatureMax = weeklyJson[index]["values"]["temperatureMax"].double ?? 0.0
                        temperatureMin = weeklyJson[index]["values"]["temperatureMin"].double ?? 0.0
                        windSpeed = weeklyJson[index]["values"]["windSpeed"].double ?? 0.0
                        humidity = weeklyJson[index]["values"]["humidity"].double ?? 0.0
                        pressure = weeklyJson[index]["values"]["pressureSeaLevel"].double ?? 0.0
                        uvIndex = weeklyJson[index]["values"]["uvIndex"].int ?? 0
                        weatherCode = weeklyJson[index]["values"]["weatherCode"].int ?? 0
                        precipitation = weeklyJson[index]["values"]["precipitationProbability"].int ?? 0
                        visibility = weeklyJson[index]["values"]["visibility"].double ?? 0.0
                        cloudCover = weeklyJson[index]["values"]["cloudCover"].double ?? 0.0
                        dateString = weeklyJson[index]["values"]["sunriseTime"].stringValue
                        let sunrise = dateFormatter.date(from: dateString)!
                        dateString = weeklyJson[index]["values"]["sunsetTime"].stringValue
                        let sunset = dateFormatter.date(from: dateString)!
                        let eachDay = WeatherData(date: date, temperature: temperature, temperatureMax: temperatureMax, temperatureMin: temperatureMin, weatherCode: weatherCode, windSpeed: windSpeed, pressure: pressure, precipitation: precipitation, humidity: humidity, visibility: visibility, cloudCover: cloudCover, uvIndex: uvIndex, sunrise: sunrise, sunset: sunset)
                        weeklyWeather.append(eachDay)
                        //dump(eachDay)
                    }
                    let dataModel = WeatherDataModel(cur: current, weekly: weeklyWeather)
                    callback(dataModel)
                }
                
            case let .failure(error):
                print(error)
            }
        }
    }
    static func getSearchSuggestion(text:String, callback: @escaping ([String])->()) {
        AF.request(googleAutoCompleteApi,
                  method: .get,
                  parameters: [
                    "input": text,
                    "types": "(cities)",
                    "key": googleApiKey
                  ])
        .validate()
        .responseJSON {
            response in
            switch response.result{
                case .success(let value):
                    print("google autocomplete service success")
                    let json = JSON(value)
                    if !json.isEmpty{
                        var predictions:[String] = []
                        if json["status"] == "OK" {
                            //print("predictions count = \(json["predictions"].count)")
                            for index in 0...json["predictions"].count {
                                let city = json["predictions"][index]["terms"][0]["value"].stringValue
                                if city != "" {
                                    predictions.append(city)
                                }
                            }
                        }
                        //dump(predictions)
                        callback(predictions)
                    }
                
                case let .failure(error):
                    print(error)
            }
        }
    }
}

//
//  WeatherDataModel.swift
//  WeatherApp
//
//  Created by Kaiyuan Yu on 12/4/21.
//

import Foundation
struct WeatherData: Codable{
    var date:Date
    var temperature:Double
    var temperatureMax:Double
    var temperatureMin:Double
    var weatherCode:Int
    var windSpeed:Double
    var pressure:Double
    var precipitation:Int
    var humidity:Double
    var visibility:Double
    var cloudCover:Double
    var uvIndex:Int
    var sunrise:Date?
    var sunset:Date?
}

class WeatherDataModel: Codable{
    var city:String?
    var currentWeatherData:WeatherData
    var weeklyWeatherData:[WeatherData]
    init(cur:WeatherData, weekly:[WeatherData]){
        currentWeatherData = cur
        weeklyWeatherData = weekly
    }
        
    static func getTextFromWeatherCode(code:Int) -> String{
        switch code {
            case 4201:
                return "Heavey Rain"
            
            case 4001:
                return "Rain"
            
            case 4200:
                return "Light Rain"
            
            case 6201:
                return "Heavey Freezing Rain"
            
            case 6001:
                return "Freezing Rain"
            
            case 6200:
                return "Light Freezing Rain"
            
            case 6000:
                return "Freezing Drizzle"
            
            case 4000:
                return "Drizzle"
            
            case 7101:
                return "Heavey Ice Pellets"
            
            case 7000:
                return "Ice Pellets"
            
            case 7102:
                return "Light Ice Pellets"
            
            case 5101:
                return "Heavey Snow"
            
            case 5000:
                return "Snow"
            
            case 5100:
                return "Light Snow"
            
            case 5001:
                return "Flurries"
            
            case 8000:
                return "Thunderstorm"
            
            case 2100:
                return "Light Fog"
            
            case 2000:
                return "Fog"
            
            case 1001:
                return "Cloudy"
            
            case 1102:
                return "Mostly Cloudy"
            
            case 1101:
                return "Partly Cloudy"
            
            case 1100:
                return "Mostly Clear"
            
            case 1000:
                return "Clear"
            
            default:
                return ""
        }
    }
    static func toDateString(date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: date)
    }
    static func toTimeString(date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    static func objToJson(obj:[WeatherDataModel])->String{
        let encodedData = (try? JSONEncoder().encode(obj))!
        let jsonString = String(data: encodedData,
                                encoding: .utf8)
        //print("encoded json = " + jsonString!)
        return jsonString!
    }
    static func jsonToObj(json:String) -> [WeatherDataModel]{
        if let dataFromJsonString = json.data(using: .utf8) {
            let obj = try? JSONDecoder().decode([WeatherDataModel].self,
                                                        from: dataFromJsonString)
            
            //dump(obj)
            return obj!
        }
        return []
    }
}

//
//  WeeklyViewController.swift
//  WeatherApp
//
//  Created by Kaiyuan Yu on 12/8/21.
//

import UIKit
import Highcharts

class WeeklyViewController: UIViewController {
    
    @IBOutlet weak var card1View: UIView!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var highchartsView: UIView!
    var chartView: HIChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        card1View.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        card1View.layer.cornerRadius = 10
        card1View.layer.borderWidth = 1
        card1View.layer.borderColor = UIColor.white.cgColor
        
        let tabbar = tabBarController as! TabBarViewController
        let weatherData = (tabbar.weatherData?.currentWeatherData)!
        let weather = WeatherDataModel.getTextFromWeatherCode(code: weatherData.weatherCode)
        let weatherImage = UIImage(named: weather)
        weatherImageView.image = weatherImage
        weatherLabel.text = weather
        temperatureLabel.text = "\(weatherData.temperature) °F"
        // Do any additional setup after loading the view.
        
        let chartView = HIChartView(frame: highchartsView.bounds)
            
        let options = HIOptions()

        let chart = HIChart()
        chart.type = "arearange"
        chart.zoomType = "x"
        chart.scrollablePlotArea = HIScrollablePlotArea()
//        chart.scrollablePlotArea.minWidth = 600
        chart.scrollablePlotArea.scrollPositionX = 1
        options.chart = chart

        let title = HITitle()
        title.text = "Temperature variation by day"
        options.title = title

        let xAxis = HIXAxis()
        xAxis.type = "linear"
        xAxis.accessibility = HIAccessibility()
        xAxis.accessibility.rangeDescription = "Range: next 15 days."
        xAxis.tickInterval = 5
        options.xAxis = [xAxis]

        let yAxis = HIYAxis()
        yAxis.title = HITitle()
        yAxis.title.text = "Temperature"
        options.yAxis = [yAxis]

        let tooltip = HITooltip()
        // tooltip.crosshairs = true
        tooltip.shared = true
        tooltip.valueSuffix = "°F"
//        tooltip.xDateFormat = "%A, %b %e"
        options.tooltip = tooltip

        let legend = HILegend()
        legend.enabled = false
        options.legend = legend

        let temperatures = HIArearange()
        temperatures.name = "Temperatures"
        temperatures.data = getData(weeklyData: tabbar.weatherData!.weeklyWeatherData)

        options.series = [temperatures]
        let gradient = HILinearGradientColorObject()
        gradient.x1 = 0
        gradient.x2 = 0
        gradient.y1 = 0
        gradient.y2 = 1
        let color = HIColor.init(linearGradient: [
                                    "x1": 0,
                                    "x2": 0,
                                    "y1": 0,
                                    "y2": 1],
                                 stops: [
                                     [0, "#e08f55"],
                                     [1, "#599ad4"]
                                 ])
        
        
        options.plotOptions = HIPlotOptions()
        options.plotOptions.arearange = HIArearange()
        options.plotOptions.arearange.fillColor = color

        chartView.options = options
        

        self.highchartsView.addSubview(chartView)
    }
    private func getData(weeklyData:[WeatherData]) -> [Any] {
        var dataArray:[Any] = []
        for index in 0...14{
            dataArray.append([index, weeklyData[index].temperatureMin, weeklyData[index].temperatureMax])
        }
        return dataArray
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

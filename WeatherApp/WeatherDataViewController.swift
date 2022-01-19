//
//  WeatherDataViewController.swift
//  WeatherApp
//
//  Created by Kaiyuan Yu on 12/8/21.
//

import UIKit
import Highcharts

class WeatherDataViewController: UIViewController {
    
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    
    @IBOutlet weak var card1View: UIView!
    @IBOutlet weak var card2View: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        card1View.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        card1View.layer.cornerRadius = 10
        card1View.layer.borderWidth = 1
        card1View.layer.borderColor = UIColor.white.cgColor
        
        let tabbar = tabBarController as! TabBarViewController
        let weatherData = (tabbar.weatherData?.currentWeatherData)!
        precipitationLabel.text = "\(weatherData.precipitation) %"
        humidityLabel.text = "\(weatherData.humidity) %"
        cloudCoverLabel.text = "\(weatherData.cloudCover) %"
        
        //display chart view
        let chartView = HIChartView(frame: card2View.bounds)
            chartView.plugins = ["solid-gauge"]

            let options = HIOptions()

            let chart = HIChart()
            chart.type = "solidgauge"
            chart.height = "100%"
            options.chart = chart

            let title = HITitle()
            title.text = "Weather Data"
            title.style = HICSSObject()
            title.style.fontSize = "24px"
            options.title = title

            let tooltip = HITooltip()
            tooltip.borderWidth = 0
            tooltip.shadow = HIShadowOptionsObject()
            tooltip.shadow.opacity = 0
            tooltip.style = HICSSObject()
            tooltip.style.fontSize = "12px"
            tooltip.valueSuffix = "%"
            tooltip.pointFormat = "{series.name}<br><span style=\"font-size:18px; color: {point.color}; font-weight: bold\">{point.y}</span>"
            tooltip.positioner = HIFunction(jsFunction: "function (labelWidth) { return { x: (this.chart.chartWidth - labelWidth) / 2, y: (this.chart.plotHeight / 2) + 15 }; }")
            options.tooltip = tooltip

            let pane = HIPane()
            pane.startAngle = 0
            pane.endAngle = 360

            let background1 = HIBackground()
            background1.backgroundColor = HIColor(rgba: 150, green: 230, blue: 140, alpha: 0.35)
            background1.outerRadius = "112%"
            background1.innerRadius = "88%"
            background1.borderWidth = 0

            let background2 = HIBackground()
            background2.backgroundColor = HIColor(rgba: 140, green: 190, blue: 230, alpha: 0.35)
            background2.outerRadius = "87%"
            background2.innerRadius = "63%"
            background2.borderWidth = 0

            let background3 = HIBackground()
            background3.backgroundColor = HIColor(rgba: 250, green: 80, blue: 100, alpha: 0.35)
            background3.outerRadius = "62%"
            background3.innerRadius = "38%"
            background3.borderWidth = 0

            pane.background = [
              background1, background2, background3
            ]

            options.pane = pane

            let yAxis = HIYAxis()
            yAxis.min = 1
            yAxis.max = 100
            yAxis.lineWidth = 0
            yAxis.tickPosition = ""
            options.yAxis = [yAxis]

            let plotOptions = HIPlotOptions()
            plotOptions.solidgauge = HISolidgauge()
            let dataLabels = HIDataLabels()
            dataLabels.enabled = false
            plotOptions.solidgauge.dataLabels = [dataLabels]
            plotOptions.solidgauge.linecap = "round"
            plotOptions.solidgauge.stickyTracking = false
            plotOptions.solidgauge.rounded = true
            options.plotOptions = plotOptions

            let cloudCover = HISolidgauge()
            cloudCover.name = "Cloud Cover"
            let cloudCoverData = HIData()
            cloudCoverData.color = HIColor(rgba: 150, green: 240, blue: 140, alpha: 1)
            cloudCoverData.radius = "112%"
            cloudCoverData.innerRadius = "88%"
            cloudCoverData.y = NSNumber.init(value: weatherData.cloudCover)
            cloudCover.data = [cloudCoverData]

            let humidity = HISolidgauge()
            humidity.name = "Humidity"
            let humidityData = HIData()
            humidityData.color = HIColor(rgba: 140, green: 190, blue: 230, alpha: 1)
            humidityData.radius = "87%"
            humidityData.innerRadius = "63%"
            humidityData.y = NSNumber.init(value: weatherData.humidity)
            humidity.data = [humidityData]

            let precipitation = HISolidgauge()
            precipitation.name = "Precipitation"
            let precipitationData = HIData()
            precipitationData.color = HIColor(rgba: 250, green: 80, blue: 100, alpha: 1)
            precipitationData.radius = "62%"
            precipitationData.innerRadius = "38%"
            precipitationData.y = NSNumber.init(value: weatherData.precipitation)
            precipitation.data = [precipitationData]

            options.series = [cloudCover, humidity, precipitation]

            chartView.options = options

            self.card2View.addSubview(chartView)
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

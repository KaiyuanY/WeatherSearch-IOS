//
//  WeeklyTableViewCell.swift
//  WeatherApp
//
//  Created by Kaiyuan Yu on 12/6/21.
//

import UIKit

class WeeklyTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    
    func configureCell(date:String, imageName:String, sunrise:String, sunset:String){
        dateLabel.text = date
        weatherImageView.image = UIImage(named: imageName)
        sunriseLabel.text = sunrise
        sunsetLabel.text = sunset
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

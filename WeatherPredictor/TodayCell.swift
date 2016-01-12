//
//  TodayCell.swift
//  WeatherPredictor
//
//  Created by BolloMini on 28/11/15.
//  Copyright © 2015 Bollagardar Productions. All rights reserved.
//

import UIKit

class TodayCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

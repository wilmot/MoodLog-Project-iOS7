//
//  MlCell.swift
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 9/9/14.
//  Copyright (c) 2014 Barry A. Langdon-Lassagne. All rights reserved.
//

import UIKit

class MlCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var calendarImage: UIImageView!
    @IBOutlet weak var subLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

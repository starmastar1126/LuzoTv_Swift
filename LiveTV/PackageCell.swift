//
//  PackageCell.swift
//  LiveTV
//
//  Created by Aqib  Farooq on 30/09/2019.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class PackageCell: UITableViewCell {
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var validityLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

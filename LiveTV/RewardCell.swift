//
//  RewardCell.swift
//  LiveTV
//
//  Created by Aqib  Farooq on 19/09/2019.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class RewardCell: UICollectionViewCell
{
    @IBOutlet var imageBackView : UIView?
    @IBOutlet var iconImageView : UIImageView?
    @IBOutlet var lblRewardName : UILabel?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }
    
    override func draw(_ rect: CGRect)
    {
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
    }
}

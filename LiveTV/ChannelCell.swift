//
//  LatestCollectionCell.swift
//  LiveTV
//
//  Created by Apple on 11/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class ChannelCell: UICollectionViewCell
{
    @IBOutlet var imageBackView : UIView?
    @IBOutlet var iconImageView : UIImageView?
    @IBOutlet var lblChannelName : UILabel?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }
    
    override func draw(_ rect: CGRect)
    {
        //1.Set Cell Corner Radius
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
    }
}

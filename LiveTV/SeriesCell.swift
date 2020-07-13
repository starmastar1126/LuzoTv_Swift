//
//  SeriesCell.swift
//  LiveTV
//
//  Created by Apple on 13/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class SeriesCell: UICollectionViewCell
{
    @IBOutlet var imageBackView : UIView?
    @IBOutlet var iconImageView : UIImageView?
    @IBOutlet var lblSeriesName : UILabel?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }
    
    override func draw(_ rect: CGRect)
    {
        //1.Set Cell Corner Radius
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
        
        //2.Icon Imageview Shadow
        self.iconImageView?.backgroundColor = UIColor.lightGray
        let gradient = CAGradientLayer()
        gradient.frame = (self.iconImageView?.layer.bounds)!
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        ]
        self.iconImageView?.layer.sublayers?[0].removeFromSuperlayer()
        self.iconImageView?.layer.addSublayer(gradient)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
    }
}

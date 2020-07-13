//
//  MovieCell.swift
//  LiveTV
//
//  Created by Apple on 12/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class MovieCell: UICollectionViewCell
{
    @IBOutlet var imageBackView : UIView?
    @IBOutlet var iconImageView : UIImageView?
    @IBOutlet var lblLanguageName : UILabel?
    @IBOutlet var lblMovieName : UILabel?
    
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
        
        //3.Language Background Corner Radius
//        let bounds: CGRect = self.lblLanguageName!.bounds
//        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: self.lblLanguageName!.bounds.size)
//        let maskLayer = CAShapeLayer()
//        maskLayer.frame = bounds
//        maskLayer.path = maskPath.cgPath
//        self.lblLanguageName?.layer.mask = maskLayer
        
        let bounds: CGRect = self.lblLanguageName!.bounds
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: self.lblLanguageName!.bounds.size)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        self.lblLanguageName?.layer.mask = maskLayer
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
    }
}

//
//  GenreCell.swift
//  LiveTV
//
//  Created by Apple on 01/08/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class GenreCell: UICollectionViewCell
{
    @IBOutlet var myView : UIView?
    @IBOutlet var iconImageView : UIImageView?
    @IBOutlet var lblGenreName : UILabel?
    
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

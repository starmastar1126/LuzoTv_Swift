//
//  LanguageCell.swift
//  LiveTV
//
//  Created by Apple on 31/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class LanguageCell: UICollectionViewCell
{
    @IBOutlet var myView : UIView?
    @IBOutlet var lblLanguageName : UILabel?
    
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

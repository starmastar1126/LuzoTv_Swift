//
//  TVCategoryCollectionCell.swift
//  LiveTV
//
//  Created by Apple on 09/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell
{
    @IBOutlet var imageBackView : UIView?
    @IBOutlet var iconImageView : UIImageView?
    @IBOutlet var lblCatName : UILabel?
    
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

//
//  EpisodeCell.swift
//  LiveTV
//
//  Created by Apple on 07/08/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class EpisodeCell: UICollectionViewCell
{
    @IBOutlet var myBackView : UIView?
    @IBOutlet var iconImageView : UIImageView?
    @IBOutlet var lblPlayingNow : UILabel?
    @IBOutlet var lblEpisodeName : UILabel?
    
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

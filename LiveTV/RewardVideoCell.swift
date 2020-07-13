//
//  RewardVideoCell.swift
//  LiveTV
//
//  Created by Aqib  Farooq on 20/09/2019.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
protocol adDelegate : class {    // 'class' means only class types can implement it
    func visitAdvertiser(_ sender:RewardVideoCell)
    
}
class RewardVideoCell: UICollectionViewCell {
    @IBOutlet var imageBackView : UIView?
    @IBOutlet var iconImageView : UIImageView?
    @IBOutlet weak var advertisorBtn: UIButton!
    
    weak var delegate : adDelegate?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }
    
    override func draw(_ rect: CGRect)
    {
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
    }

    @IBAction func visitList(_ sender: Any) {
       delegate?.visitAdvertiser(self)
    }
}

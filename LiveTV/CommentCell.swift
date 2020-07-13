//
//  CommentCell.swift
//  LiveTV
//
//  Created by Apple on 22/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell
{
    @IBOutlet var myView : UIView?
    @IBOutlet var imgLogo : UIImageView?
    @IBOutlet var lblusername : UILabel?
    @IBOutlet var lbldate : UILabel?
    @IBOutlet var lblcomment : UILabel?
    
    var minHeight: CGFloat?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize
    {
        let size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
        guard let minHeight = minHeight else { return size }
        return CGSize(width: size.width, height: max(size.height, minHeight))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
    }
}

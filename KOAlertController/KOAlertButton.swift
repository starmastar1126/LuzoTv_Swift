//
//  KOAlertButton.swift
//
//  Created by Oleksandr Khymych on 13.12.2017.
//  Copyright © 2017 Oleksandr Khymych. All rights reserved.
//

import Foundation
import UIKit

/// Aler button style
open class KOAlertButton
{
    public var backgroundColor     : UIColor!
    public var titleColor          : UIColor!
    public var font                : UIFont!
    public var borderColor         : UIColor!
    public var borderWidth         : CGFloat!
    public var cornerRadius        : CGFloat!
    public var title               : String!
    public init(_ type:KOTypeButton, title:String)
    {
        self.title = title.uppercased()
        switch type
        {
        case .cancel:
            self.backgroundColor = UIColor.white
            self.titleColor      = UIColor.black
            self.font            = UIFont.boldSystemFont(ofSize: 19)
            self.borderColor     = UIColor.black
            self.borderWidth     = 1
            self.cornerRadius    = 2.0
        default:
            self.backgroundColor = UIColor(hexString: Colors.getHeaderColor1(), alpha: 1.0)
            self.titleColor      = UIColor(hexString: "FFFFFF", alpha: 0.9)
            self.font            = UIFont(name: "Montserrat-Regular", size: 20.0)
            self.borderColor     = UIColor.clear
            self.borderWidth     = 0
            self.cornerRadius    = 5.0
        }
    }
}

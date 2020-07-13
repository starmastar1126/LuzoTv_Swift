//
//  KOAlertStyle.swift
//
//  Created by Oleksandr Khymych on 13.12.2017.
//  Copyright © 2017 Oleksandr Khymych. All rights reserved.
//

import Foundation
import UIKit

/// Aler style object
open class KOAlertStyle
{
    public enum PositionType
    {
        case center
        case `default`
    }
    public var position            : PositionType = .default
    public var backgroundColor     : UIColor!
    public var titleColor          : UIColor!
    public var titleFont           : UIFont!
    public var messageColor        : UIColor!
    public var messageFont         : UIFont!
    public var cornerRadius        : CGFloat!
    public init()
    {
        self.backgroundColor    = UIColor(hexString: "#", alpha: 1.0)
        self.titleColor         = UIColor.black
        self.titleFont          = UIFont(name: "Montserrat-Regular", size: 38.0)
        self.messageFont        = UIFont(name: "Montserrat-Regular", size: 18.0)
        self.messageColor       = UIColor.gray
        self.cornerRadius       = 5
    }
}

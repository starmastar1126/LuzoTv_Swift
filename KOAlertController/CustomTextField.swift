//
//  CustomTextField.swift
//  Example
//
//  Created by Oleksandr Khymych on 26.12.2017.
//  Copyright © 2017 Oleksandr Khymych. All rights reserved.
//

import Foundation
import UIKit

/*class CustomTextField: UITextField
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.lightGray
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor(hexString: "#F0F0F0", alpha: 1.0)
        self.textColor = .darkGray
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
}*/


class CustomTextField: UITextView
{
    override init(frame: CGRect, textContainer: NSTextContainer?)
    {
        super.init(frame: frame, textContainer: textContainer)
        
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor(hexString: "#F0F0F0", alpha: 1.0)
        self.textColor = .darkGray
        self.tintColor = .darkGray
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.font = UIFont(name: "Montserrat-Medium", size: 16.0)
        self.text = CommonMessage.ReportMessage()
        self.textColor = .lightGray
    }
}

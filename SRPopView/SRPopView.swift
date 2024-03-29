//
//  SRSwiftyPopManager.swift
//  SRSwiftyPopoverDemo
//
//  Created by Administrator on 26/12/17.
//  Copyright © 2017 Order of the Light. All rights reserved.
//

import Foundation


//autlayout for popview in the window !~

public enum Result{
    case notPicked
    case picked(String,Int)
}


public enum SRBlurEffect {
    case vibrant
    case dark
    case none
}

public enum SRPopViewColorScheme{
    case dark
    case bright
    case black
    case matte
    case strangerthings
    case westworld
    case firefly
}



public typealias SRPopviewCompletion = (Result)->Void

public class SRPopview : NSObject
{
    public static let shared = SRPopview()
    
    internal(set) public var currentItems : Array<String>!
    private(set) public var originalItems : Array<String>!
    private(set) public var selectedItem = -1
    
    internal var comp : SRPopviewCompletion?
    internal var popView : SRSwiftyPopoverView!
    
    public var autoSearch = false
    public var blurBackground : SRBlurEffect = .none
    public var heading : String = ""
    public var currentColorScheme : SRPopViewColorScheme = .dark
    public var showLog : Logging = .off {
        didSet {
            logging = showLog
        }
    }
    
    
    
    
    public class func show(withValues array : Array<String>, heading hText : String, autoSearch a : Bool? = nil ,selectedIndex s : Int = 0,colorscheme cs : SRPopViewColorScheme? = nil, completion c : SRPopviewCompletion?){
        
        SRPopview.shared.currentItems            = array
        SRPopview.shared.originalItems           = array
        SRPopview.shared.selectedItem            = s
        if let hasautoSearch = a {
            SRPopview.shared.autoSearch           = hasautoSearch
        }
        
        if let hasColorScheme = cs {
            SRPopview.shared.currentColorScheme     = hasColorScheme
        }
        
        SRPopview.shared.heading                 = hText
        
        
        if let hasCompletion = c {
            SRPopview.shared.comp = hasCompletion
        }
        SRPopview.shared.configure()
        
    }

    public func reloadData(){
        popView.reloadValues()
    }
    
    public func reloadDataWithUpdatedValues(_ updatedInputValues : [String]){
        popView.allItems = updatedInputValues
        popView.reloadValues()
    }
    
    public class func dismiss(){
        SRPopview.shared.dismissAnimated()
    }
    
    private func configure(){
        
        popView = SRSwiftyPopoverView.init(withItems: currentItems, andSelectedItem: selectedItem, headingText: heading, autoSearchbar: autoSearch, blurView: blurBackground)
        popView.translatesAutoresizingMaskIntoConstraints = false
        popView.alpha = 0.0
        popView.delegate = self
        popView.configureColorScheme(self.currentColorScheme)
        popView.configure()
        self.showAnimated()
        
    }
    
    private func showAnimated(){
        let window = UIApplication.shared.keyWindow!
        window.addSubview(popView)
        NSLayoutConstraint.addConstraintsFit(ToSuperview: window, andSubview: popView)
        
        UIView.animate(withDuration: 0.3) {
            self.popView.alpha = 0.8
        }
    }
    
    internal func dismissAnimated(){
        popView.removeKeyboardNotfications()
        UIView.animate(withDuration: 0.3, animations: {
            self.popView.alpha = 0.0
        }) { (_) in
            self.cleanup()
        }
    }
    
    private func cleanup(){
        popView.removeFromSuperview()
        popView = nil
        PLOG("Cleanup Done")
    }
    
    
    
}


extension SRPopview : SRSwiftyPopviewDelegate{
    func dismissWithoutPicking() {
        dismissAnimated()
        comp?(.notPicked)
    }

    func didPickItem(str: String, index: Int) {
        comp?(.picked(str, index))
        dismissAnimated()
    }
    
    func textFieldDidChange(_ str: String) {
        PLOG(str)
        // do predicate operations --- >>>
        if(str != ""){
            currentItems = originalItems.filter{
                $0.localizedCaseInsensitiveContains(str)
            }
        }
        else {
            currentItems = originalItems
        }
        popView.allItems = currentItems
        popView.tblView.reloadData()
        
    }
    
}

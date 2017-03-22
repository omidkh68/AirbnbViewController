//
//  AirbnbSessionView.swift
//  AirbnbViewController
//
//  Created by pixyzehn on 1/1/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import Foundation
import UIKit

open class AirbnbSessionView: UIView {
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate var _button: UIButton?
    open var button: UIButton? {
        get {
            if let btn = _button {
                return btn
            } else {
                _button = UIButton.withType(UIButtonType.custom) as? UIButton
                _button?.frame = CGRect(x: 0, y: 40, width: frame.size.width, height: kHeaderTitleHeight - 40.0)
                _button?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
                addSubview(_button!)
                return _button
            }
        }
        set {
            _button = newValue
        }
    }

    fileprivate var _containView: UIView?
    open var containView: UIView? {
        get {
            if let cv = _containView {
                return cv
            } else {
                _containView = UIView(frame: CGRect(x: 0, y: kHeaderTitleHeight + 20, width: frame.size.width, height: frame.size.height - kHeaderTitleHeight))
                addSubview(_containView!)
                return _containView
            }
        }
        set {
            _containView = newValue
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    deinit {
        self.button?.removeFromSuperview()
        self.button = nil
        self.containView?.removeFromSuperview()
        self.containView = nil
    }
}

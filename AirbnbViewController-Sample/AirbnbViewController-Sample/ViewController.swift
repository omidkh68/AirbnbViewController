//
//  ViewController.swift
//  AirbnbViewController-Sample
//
//  Created by pixyzehn on 1/27/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        let button: UIButton = UIButton(type:UIButtonType.custom)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 35)
        button.setTitle("Menu", for: UIControlState())
        button.setTitleColor(UIColor(red:0.3, green:0.69, blue:0.75, alpha:1), for: UIControlState())
        button.addTarget(self, action: #selector(ViewController.leftButtonTouch), for: UIControlEvents.touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        self.airSwipeHandler = {() -> Void in
            self.airViewController.showAirViewFromViewController(self.navigationController, complete: nil)
            return
        }
    }
    
    func leftButtonTouch() {
        self.airViewController.showAirViewFromViewController(self.navigationController, complete: nil)
    }
}


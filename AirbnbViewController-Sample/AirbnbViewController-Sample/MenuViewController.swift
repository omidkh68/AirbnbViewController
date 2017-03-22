//
//  MenuViewController.swift
//  AirbnbViewController-Sample
//
//  Created by pixyzehn on 1/27/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

class MenuViewController: AirbnbViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }
        
    //MARK: AirbnbMenuDataSource

    override func numberOfSession() -> Int {
        return 10
    }
    
    override func numberOfRowsInSession(_ session: Int) -> Int {
        return 3
    }
    
    override func titleForRowAtIndexPath(_ indexPath: IndexPath) -> String {
        return "Row \(indexPath.row) in \(indexPath.section)"
    }
    
    override func titleForHeaderAtSession(_ session: Int) -> String {
        return "Session \(session)"
    }
    
    func viewControllerForIndexPath(_ indexPath: IndexPath) -> UIViewController {
        let viewController: ViewController = ViewController()
        
        let controller: UINavigationController = UINavigationController(rootViewController: viewController)
        
        switch indexPath.row {
        case 0:
            viewController.view.backgroundColor = UIColor(red:0.13, green:0.14, blue:0.15, alpha:1)
        case 1:
            viewController.view.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1)
        case 2:
            viewController.view.backgroundColor = UIColor(red:0.8, green:0, blue:0.48, alpha:1)
        default:
            break
        }
        return controller
    }
    
    //MARK: AirbnbMenuDelegate
    
    func didSelectRowAtIndex(_ indexPath: IndexPath) {
        print("didSelectRowAtIndex:\(indexPath.row)\n")
    }
    
    func shouldSelectRowAtIndex(_ indexPath: IndexPath) -> Bool {
        return true
    }
    
    func willShowAirViewController() {
        print("willShowAirViewController\n")
    }
    
    func willHideAirViewController() {
        print("willHideAirViewController\n")
    }
    
    func didHideAirViewController() {
        print("didHideAirViewController\n")
    }
    
    func heightForAirMenuRow() -> CGFloat {
        return 90.0
    }
    
    func indexPathDefaultValue() -> IndexPath? {
        return IndexPath(index: 2)
    }
}

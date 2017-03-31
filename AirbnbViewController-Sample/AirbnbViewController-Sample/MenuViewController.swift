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
    
    func imageForRowAtIndexPath(_ indexPath: IndexPath) -> UIImage {
        return drawRandomCircle()
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
    
    //MARK: Utilities
    
    func drawRandomCircle() -> UIImage {
        let scale = UIScreen.main.scale
        let frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        
        guard context != nil else {
            return UIImage()
        }
        
        let circlePath = CGPath(ellipseIn: frame, transform: nil)
        context!.addPath(circlePath)
        context!.clip()
        
        let bgColor = generateRandomColor().cgColor
        context!.setFillColor(bgColor)
        context!.fill(frame)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = image {
            return image
        }
        else {
            return UIImage()
        }
    }
    
    func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
}

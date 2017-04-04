//
//  AirbnbViewController.swift
//  AirbnbViewController
//
//  Created by pixyzehn on 1/1/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import Foundation
import UIKit


@objc public protocol AirbnbMenuDelegate: NSObjectProtocol {
    @objc optional func shouldSelectRowAtIndex(_ indexPath: IndexPath) -> Bool
    @objc optional func didSelectRowAtIndex(_ indexPath: IndexPath)
    @objc optional func willShowAirViewController()
    @objc optional func willHideAirViewController()
    @objc optional func didHideAirViewController()
    @objc optional func heightForAirMenuRow() -> CGFloat
    @objc optional func indexPathDefaultValue() -> IndexPath?
}

@objc public protocol AirbnbMenuDataSource: NSObjectProtocol {
    func numberOfSession() -> Int
    func numberOfRowsInSession(_ sesion: Int) -> Int
    func titleForRowAtIndexPath(_ indexPath: IndexPath) -> String
    func titleForHeaderAtSession(_ session: Int) -> String
    @objc optional func imageForRowAtIndexPath(_ indexPath: IndexPath) -> UIImage
    @objc optional func thumbnailImageAtIndexPath(_ indexPath: IndexPath) -> UIImage?
    @objc optional func viewControllerForIndexPath(_ indexPath: IndexPath) -> UIViewController
}

public let kSessionWidth: CGFloat          = 220
public let kLeftViewTransX: CGFloat        = -50
public let kLeftViewRotate: CGFloat        = -5
public let kAirImageViewRotate: CGFloat    = -25
public let kRightViewTransX: CGFloat       = 180
public let kRightViewTransZ: CGFloat       = -150
public let kAirImageViewRotateMax: CGFloat = -42
public let kDuration                       = 0.2
public let kIndexPathOutMenu               = IndexPath(row: 999, section: 0)
public let kHeaderTitleHeight: CGFloat     = 80

//MARK: Convert unit

private var AirDegreesToRadians = {(degrees: CGFloat) -> CGFloat in
    return degrees * CGFloat(Double.pi) / 180.0
}

private var AirRadiansToDegrees = {(radians: CGFloat) -> CGFloat in
    return radians * 180 / CGFloat(Double.pi)
}

open class AirbnbViewController: UIViewController, AirbnbMenuDelegate, AirbnbMenuDataSource, UIGestureRecognizerDelegate {
 
    open var titleNormalColor = UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0)
    open var titleHighlightColor = UIColor.black
    open var delegate: AirbnbMenuDelegate?
    open var dataSource: AirbnbMenuDataSource?
    open var frontViewController: UIViewController?
    open var currentIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    open let complete = ({ () -> Void in })
   
    fileprivate var _wrapperView: UIView?
    open var wrapperView: UIView? {
        get {
            if let wv = _wrapperView {
                return wv
            } else {
                let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
                _wrapperView = view
                return view
            }
        }
        set {
            _wrapperView = newValue
        }
    }

    fileprivate var _contentView: UIView?
    open var contentView: UIView? {
        get {
            if let cv = _contentView {
                return cv
            } else {
                let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
                _contentView = view
                return view
            }
        }
        set {
            _contentView = newValue
        }
    }
    
    fileprivate var _leftView: UIView?
    open var leftView: UIView? {
        get {
            if let lv = _leftView {
                return lv
            } else {
                let view: UIView = UIView(frame: CGRect(x: 0, y: -(self.view.height - kHeaderTitleHeight), width: kSessionWidth, height: (self.view.height - kHeaderTitleHeight) * 3))
                view.isUserInteractionEnabled = true
                _leftView = view
                return view
            }
        }
        set {
            _leftView = newValue
        }
    }
    
    fileprivate var _rightView: UIView?
    open var rightView: UIView? {
        get {
            if let rv = _rightView {
                return rv
            } else {
                let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
                view.isUserInteractionEnabled = true
                _rightView = view
                return view
            }
        }
        set {
            _rightView = newValue
        }
    }
    
    fileprivate var _airImageView: UIImageView?
    open var airImageView: UIImageView? {
        get {
            if let aiv = _airImageView {
                return aiv
            } else {
                let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
                imageView.isUserInteractionEnabled = true
                _airImageView = imageView
                return imageView
            }
        }
        set {
            _airImageView = newValue
        }
    }

    fileprivate var lastDeegreesRotateTransform: CGFloat?
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer?
    
    open var session: Int?
    open var rowsOfSession: [Int]?
    open var sessionViews: Dictionary<Int, AirbnbSessionView>?
    open var currentIndexSession: Int = 0
    open var isAnimation: Bool?
    open var topSession: AirbnbSessionView?
    open var middleSession: AirbnbSessionView?
    open var bottomSession: AirbnbSessionView?
    open var lastIndexInSession: Dictionary<Int, Int> = [0:0]
    open var thumbnailImages: [Dictionary<Int, UIImage>]?
    open var viewControllers: [Dictionary<Int, UIViewController>]?
    open var heightAirMenuRow: CGFloat?
 
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience public init(viewController: UIViewController, atIndexPath:IndexPath) {
        self.init()
        let rect = UIScreen.main.bounds
        self.view.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
        self.bringViewControllerToTop(viewController, indexPath: atIndexPath)
        self.setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    fileprivate func setup() {
        sessionViews = Dictionary<Int, AirbnbSessionView>()
        currentIndexPath = IndexPath(item: 0, section: 0)
        
        self.delegate = self
        self.dataSource = self
        
        self.leftView?.alpha = 0
        self.rightView?.alpha = 0
        
        self.heightAirMenuRow = 44
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(wrapperView!)
        self.wrapperView?.addSubview(contentView!)
        self.contentView?.addSubview(leftView!)
        self.contentView?.addSubview(rightView!)
        self.rightView?.addSubview(airImageView!)

        
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(AirbnbViewController.handleSwipeOnAirImageView(_:)))
        swipe.direction = UISwipeGestureRecognizerDirection.left
        self.airImageView?.addGestureRecognizer(swipe)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AirbnbViewController.handleTapOnAirImageView(_:)))
        self.airImageView?.addGestureRecognizer(tap)
        
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(AirbnbViewController.handleRevealGesture(_:)))
        self.panGestureRecognizer?.delegate = self
        self.leftView?.addGestureRecognizer(panGestureRecognizer!)
        
        self.setupAnimation()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
    
    open func bringViewControllerToTop(_ controller: UIViewController?, indexPath: IndexPath) {
        
        if (controller == nil) {
            return
        }
        
        if let fvController = self.frontViewController {
            fvController.removeFromParentViewController()
            fvController.view.removeFromSuperview()
        }
        
        self.frontViewController = controller
        self.currentIndexPath = indexPath
        
        if indexPath.row != kIndexPathOutMenu.row {
            self.lastIndexInSession[indexPath.section] = indexPath.row
            self.saveViewControler(controller, atIndexPath: indexPath)
        }
        
        self.addChildViewController(self.frontViewController!)
        let controllerView: UIView = self.frontViewController!.view
        controllerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        controllerView.frame = self.view.bounds
        self.view.addSubview(controllerView)
        
        self.frontViewController?.didMove(toParentViewController: self)
    }
    
    //MARK: Gesture delegate

    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if isAnimation == true {
            return false
        }
        return true
    }
    
    //MARK: AirImageView gesture
    
    open func handleSwipeOnAirImageView(_ swipe: UISwipeGestureRecognizer) {
        self.hideAirViewOnComplete({() -> Void in
            self.bringViewControllerToTop(self.frontViewController, indexPath: self.currentIndexPath)
        })
    }
    
    open func handleTapOnAirImageView(_ swipe: UITapGestureRecognizer) {
        self.hideAirViewOnComplete({() -> Void in
            self.bringViewControllerToTop(self.frontViewController, indexPath: self.currentIndexPath)
        })
    }
    
    //MARK: Gesture Based Reveal

    open func handleRevealGesture(_ recognizer: UIPanGestureRecognizer) {
        
        if self.sessionViews?.count == 0 || self.sessionViews?.count == 1 {
            return
        }
        
        switch recognizer.state {
        case UIGestureRecognizerState.began:
            handleRevealGestureStateBeganWithRecognizer(recognizer)
        case UIGestureRecognizerState.changed:
            handleRevealGestureStateChangedWithRecognizer(recognizer)
        case UIGestureRecognizerState.ended:
            handleRevealGestureStateEndedWithRecognizer(recognizer)
        case UIGestureRecognizerState.cancelled:
            handleRevealGestureStateCancelledWithRecognizer(recognizer)
        default:
            break
        }
    }
    
    open func handleRevealGestureStateBeganWithRecognizer(_ recognizer: UIPanGestureRecognizer) {
    }
    
    open func handleRevealGestureStateChangedWithRecognizer(_ recognizer: UIPanGestureRecognizer) {
        
        let translation: CGFloat = recognizer.translation(in: self.leftView!).y

        self.leftView!.top = -(self.view.height - kHeaderTitleHeight) + translation
        
        let firstTop: Int = -Int(self.view.height - kHeaderTitleHeight)
        let afterTop: Int = Int(self.leftView!.top)
        
        let sessionViewHeight: Int = Int(self.view.height - kHeaderTitleHeight)
        var distanceScroll: Int = 0
        
        if afterTop - firstTop > 0 {
            let topMiddleSessionView: Int = Int(self.leftView!.top) + sessionViewHeight + 40
            
            if topMiddleSessionView < Int(self.view.height / 2) {
                distanceScroll = Int(self.view.height / 2) - topMiddleSessionView
            } else {
                distanceScroll = topMiddleSessionView - Int(self.view.height / 2) + 40
            }
        } else {
            let bottomMiddleSessionView: Int = Int(self.leftView!.top) + sessionViewHeight * 2
            
            if bottomMiddleSessionView > Int(self.view.height / 2) {
                distanceScroll = bottomMiddleSessionView - Int(self.view.height / 2)
            } else {
                distanceScroll = Int(self.view.height / 2) - bottomMiddleSessionView
            }
        }
        
        distanceScroll = abs(Int(self.view.height / 2) - distanceScroll)
        
        let rotateDegress: CGFloat = CGFloat(distanceScroll * Int(abs(kAirImageViewRotateMax - kAirImageViewRotate))) / (self.view.height / 2)
        self.lastDeegreesRotateTransform = rotateDegress
        
        var airImageRotate: CATransform3D = CATransform3DIdentity
        airImageRotate = CATransform3DRotate(airImageRotate, AirDegreesToRadians(kAirImageViewRotate - rotateDegress), 0, 1, 0)
        self.airImageView?.layer.transform = airImageRotate
    }
    
    //MARK: Judge whether to transit or not
    
    open func handleRevealGestureStateEndedWithRecognizer(_ recognizer: UIPanGestureRecognizer) {
        
        if sessionViews?.count == 0 {
            return
        }
        
        let firstTop: Int = -Int(self.view.height - kHeaderTitleHeight)
        let afterTop: Int = Int(self.leftView!.top)
        
        let velocity: CGPoint = recognizer.velocity(in: recognizer.view)
        
        if afterTop - firstTop > 0 {
            if afterTop - firstTop > Int(self.view.height / 2) - 40 || abs(velocity.y) > 100 {
                self.prevSession()
            } else {
                self.slideCurrentSession()
            }
        } else {
            if firstTop - afterTop > Int(self.view.height / 2) - 40 || abs(velocity.y) > 100 {
                self.nextSession()
            } else {
                self.slideCurrentSession()
            }
        }
    }
    
    open func handleRevealGestureStateCancelledWithRecognizer(_ recognizer: UIPanGestureRecognizer) {
    }
    
    open func nextSession() {
        self.currentIndexSession += 1
        if self.currentIndexSession >= (self.sessionViews?.count)! {
            self.currentIndexSession = 0
        }
        
        if let index = self.lastIndexInSession[self.currentIndexSession] {
            let lastIndexInThisSession: IndexPath = IndexPath(row:index, section: self.currentIndexSession)
            let nextThumbnail: UIImage? = self.getThumbnailForIndexPath(lastIndexInThisSession)
            if let image = nextThumbnail {
                self.airImageView?.image = image
            }
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {[weak self]() -> Void in
                self?.leftView?.top = -(self!.leftView!.height / 3.0) * 2.0
                return
            }, completion: {(finished: Bool) -> Void in
                self.layoutContaintView()
        })
        
        self.rotateAirImage()
    }
    
    open func prevSession() {
        self.currentIndexSession -= 1
        if self.currentIndexSession < 0 {
            self.currentIndexSession = self.sessionViews!.count - 1
        }
        
        if let index = self.lastIndexInSession[self.currentIndexSession] {
            let lastIndexInThisSession: IndexPath = IndexPath(row: index, section: self.currentIndexSession)
            let prevThumbnail: UIImage? = self.getThumbnailForIndexPath(lastIndexInThisSession)
            if let prev = prevThumbnail {
                self.airImageView?.image = prev
            }
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {[weak self]() -> Void in
            self?.leftView?.top = 0
            return
            }, completion: {(finished: Bool) -> Void in
                self.layoutContaintView()
        })
        
        self.rotateAirImage()
    }
    
    open func slideCurrentSession() {
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {[weak self]() -> Void in
            self!.leftView!.top = -self!.leftView!.height / 3.0
            return
            }, completion: {(finished: Bool) -> Void in
        })
        
        self.rotateAirImage()
    }
    
    open func rotateAirImage() {
        if self.lastDeegreesRotateTransform! > CGFloat(0) {
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {[weak self]() -> Void in
                    var airImageRotate: CATransform3D = self!.airImageView!.layer.transform
                    airImageRotate = CATransform3DRotate(airImageRotate, CGFloat(AirDegreesToRadians(self!.lastDeegreesRotateTransform!)),0,1,0)
                    self?.airImageView?.layer.transform = airImageRotate
                }, completion: {(finished: Bool) -> Void in
                    self.lastDeegreesRotateTransform = 0
            })
        } else {
            let rotateDegress: CGFloat = abs(kAirImageViewRotateMax - kAirImageViewRotate) as CGFloat
            
            UIView.animate(withDuration: 0.15, delay: 0, options: UIViewAnimationOptions(), animations: {[weak self]() -> Void in
                    var airImageRotate: CATransform3D = self!.airImageView!.layer.transform
                    airImageRotate = CATransform3DRotate(airImageRotate, AirDegreesToRadians(-rotateDegress), 0, 1, 0)
                    self?.airImageView?.layer.transform = airImageRotate
                
                return
                }, completion: {(finished: Bool) -> Void in
                    UIView.animate(withDuration: 0.15, delay: 0, options: UIViewAnimationOptions(),  animations: {[weak self]() -> Void in
                            var airImageRotate: CATransform3D = self!.airImageView!.layer.transform
                            airImageRotate = CATransform3DRotate(airImageRotate, AirDegreesToRadians(rotateDegress), 0, 1, 0)
                            self?.airImageView?.layer.transform = airImageRotate
                            return
                        }, completion: {(finished: Bool) -> Void in
                            self.lastDeegreesRotateTransform = 0
                    })
            })
        }
    }
    
    open func reloadData() {
        if self.dataSource == nil {
            return
        }
        
        self.session = self.dataSource?.numberOfSession()
        
        if let heightForAirMenuRow = self.delegate?.heightForAirMenuRow?() {
            self.heightAirMenuRow = heightForAirMenuRow
        }
        
        var tempThumbnails: [Dictionary<Int, UIImage>] = [Dictionary<Int, UIImage>()]
        var tempViewControllers: [Dictionary<Int, UIViewController>] = [Dictionary<Int, UIViewController>()]
        
        for _ in (0 ..< self.session!) {
            tempThumbnails.append(Dictionary<Int, UIImage>())
            tempViewControllers.append(Dictionary<Int, UIViewController>())
        }
        self.thumbnailImages = tempThumbnails
        self.viewControllers = tempViewControllers
        
        var temp: Array = [Int]()
        for i in (0 ..< self.session!) {
            temp.append(self.dataSource!.numberOfRowsInSession(i))
            
        }
        self.rowsOfSession = temp
        
        let sessionHeight: CGFloat = CGFloat(self.view.frame.size.height - kHeaderTitleHeight)
        
         for i in (0 ..< self.session!) {
            var sessionView: AirbnbSessionView? = self.sessionViews![i]
            if sessionView == nil {
                sessionView = AirbnbSessionView(frame:CGRect(x: 30, y: 0, width: kSessionWidth, height: sessionHeight))
                sessionView?.button?.setTitleColor(UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0), for: UIControlState())
                sessionView?.button?.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 20)
                sessionView?.button?.tag = i
                sessionView?.button?.addTarget(self, action: #selector(AirbnbViewController.sessionButtonTouch(_:)), for: UIControlEvents.touchUpInside)
                self.sessionViews![i] = sessionView!
            }
            let sesionTitle: String? = self.dataSource?.titleForHeaderAtSession(i)
            sessionView?.button?.setTitle(sesionTitle, for: UIControlState())
        }
        
         for i in (0 ..< self.session!) {
            let sessionView: AirbnbSessionView? = sessionViews![i]!

            for view in sessionView!.containView!.subviews {
                view.removeFromSuperview()
            }
            
            var firstTop: Int = (Int(sessionView!.containView!.frame.size.height) - (self.rowsOfSession![i] * Int(self.heightAirMenuRow!))) / 2

            if firstTop < 0 {
                firstTop = 0
            }
            
            for j in (0 ..< self.rowsOfSession![i]) {
                let currentIndexPath = IndexPath(row: j, section: i)
                let title: String = self.dataSource!.titleForRowAtIndexPath(currentIndexPath)
                let button: UIButton? = UIButton(type:UIButtonType.custom)
                button!.setTitle(title, for: UIControlState())
                button!.addTarget(self, action: #selector(AirbnbViewController.rowDidTouch(_:)), for: UIControlEvents.touchUpInside)
                button!.setTitleColor(self.titleNormalColor, for: UIControlState())
                button!.tintColor = self.titleNormalColor
                button!.setTitleColor(self.titleHighlightColor, for: UIControlState.highlighted)
                button!.setTitleColor(self.titleHighlightColor, for: UIControlState.selected)
                button!.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 16)
                button!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
                if let image = self.dataSource!.imageForRowAtIndexPath?(currentIndexPath) {
                    button!.setImage(image.withRenderingMode(.alwaysTemplate), for: UIControlState())
                    button?.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
                }
                let y: CGFloat = CGFloat(firstTop) + CGFloat(self.heightAirMenuRow!) * CGFloat(j)
                button!.frame = CGRect(x: 0, y: y, width: 200, height: CGFloat(self.heightAirMenuRow!))
                button!.tag = j
                sessionView!.containView!.tag = i
                sessionView?.containView?.addSubview(button!)
            }
        }
        self.layoutContaintView()
    }
    
    open func layoutContaintView() {
        if sessionViews!.count == 1 {
            middleSession = sessionViews![0]
            self.topSession = nil
            self.bottomSession = nil
            
            middleSession?.top = middleSession!.height
            self.leftView?.addSubview(middleSession!)
            
            self.leftView?.top = -(self.leftView!.height) / 3
            
            self.updateButtonColor()
            return
        }
        
        if self.topSession?.superview != nil {
            self.topSession?.removeFromSuperview()
            self.topSession = nil
        }
        
        if self.middleSession?.superview != nil {
            self.middleSession?.removeFromSuperview()
            self.middleSession = nil
        }
        
        if self.bottomSession?.superview != nil {
            self.bottomSession?.removeFromSuperview()
            self.bottomSession = nil
        }

        if sessionViews!.count == 1 {
            // count 1
            self.middleSession = self.sessionViews![0]
            self.topSession = self.duplicate(self.middleSession!) as? AirbnbSessionView
            self.bottomSession = self.duplicate(self.middleSession!) as? AirbnbSessionView
        } else if sessionViews!.count == 2 {
            // count 2
            self.middleSession = self.sessionViews![self.currentIndexSession]
            if currentIndexSession == 0 {
                self.topSession = self.sessionViews![1]!
                self.bottomSession = self.duplicate(self.sessionViews![1]!) as? AirbnbSessionView
            } else {
                self.topSession = self.sessionViews![0]!
                self.bottomSession = self.duplicate(self.sessionViews![0]!) as? AirbnbSessionView
            }
        } else {
            //count more than 3
            self.middleSession = sessionViews![self.currentIndexSession]
            if self.currentIndexSession == 0 {
                self.topSession = self.sessionViews![self.sessionViews!.count - 1]
            } else {
                self.topSession = self.sessionViews![self.currentIndexSession - 1]
            }
            if self.currentIndexSession + 1 >= (self.sessionViews?.count)! {
                self.bottomSession = sessionViews![0]
            } else {
                self.bottomSession = self.sessionViews![self.currentIndexSession + 1]
            }
        }
        
        self.topSession!.top    = 0
        self.middleSession!.top = self.topSession!.bottom
        self.bottomSession!.top = self.middleSession!.bottom
        
        self.leftView?.addSubview(self.topSession!)
        self.leftView?.addSubview(self.middleSession!)
        self.leftView?.addSubview(self.bottomSession!)
        
        self.leftView!.top = -(self.leftView!.height)/3
        
        self.updateButtonColor()
    }
    
    open func updateButtonColor() {
        for i in (0 ..< self.sessionViews!.count) {
            let sessionView: AirbnbSessionView? = self.sessionViews?[i]
            let indexHighlight: Int? = self.lastIndexInSession[i]
            
            for object in sessionView!.containView!.allSubviews {
                if object is UIButton {
                    let button: UIButton = object as! UIButton
                    button.isHighlighted = button.tag == indexHighlight ? true : false
                }
            }
        }
    }
    
    //MARK: PHAirMenuDelegate
    
    open func numberOfSession() -> Int {
        return 0
    }
    
    open func numberOfRowsInSession(_ sesion: Int) -> Int {
        return 0
    }
    
    open func titleForRowAtIndexPath(_ indexPath: IndexPath) -> String {
        return ""
    }
    
    open func titleForHeaderAtSession(_ session: Int) -> String {
        return ""
    }
    
    //MARK: Button action
    
    open func sessionButtonTouch(_ buttton: UIButton) {
        if buttton.tag == self.currentIndexSession {
            return
        } else {
            self.nextSession()
        }
    }
    
    open func rowDidTouch(_ button: UIButton) {

        self.lastIndexInSession[self.currentIndexSession] = button.superview!.tag
        
        self.currentIndexPath = IndexPath(row: button.tag, section: button.superview!.tag)
        
        if self.delegate != nil && self.delegate?.responds(to: #selector(AirbnbMenuDelegate.didSelectRowAtIndex(_:))) != nil {
            self.delegate?.didSelectRowAtIndex!(self.currentIndexPath)
        }
        
        var shouldSelectRow = true
        if self.delegate != nil && self.delegate?.responds(to: #selector(AirbnbMenuDelegate.shouldSelectRowAtIndex(_:))) != nil {
            shouldSelectRow = (self.delegate?.shouldSelectRowAtIndex!(self.currentIndexPath))!
        }
        guard shouldSelectRow else { return }
        
        if let nextThumbnail = self.getThumbnailForIndexPath(self.currentIndexPath) {
            self.airImageView!.image = nextThumbnail
        }
        
        self.hideAirViewOnComplete({() -> Void in
            let controller: UIViewController? = self.getViewControllerAtIndexPath(self.currentIndexPath)
            if controller != nil {
                self.bringViewControllerToTop(controller, indexPath: self.currentIndexPath)
            } else {
                let controller: UIViewController! = self.dataSource?.viewControllerForIndexPath!(self.currentIndexPath)
                self.bringViewControllerToTop(controller, indexPath: self.currentIndexPath)
            }
            
        })
    }
    
    //MARK: Show/Hide air view controller
    
    open func showAirViewFromViewController(_ controller: UIViewController?, complete: (() -> Void)? ) {
        self.updateButtonColor()
        
        if let willShow: () = self.delegate?.willShowAirViewController?() {
            willShow
        }
        
        self.airImageView?.image = self.imageWithView(controller!.view)
        self.saveThumbnailImage(self.airImageView?.image, atIndexPath: self.currentIndexPath)
        self.saveViewControler(controller, atIndexPath: self.currentIndexPath)
        
        self.view.bringSubview(toFront: self.wrapperView!)
        self.contentView?.bringSubview(toFront: self.leftView!)
        self.contentView?.bringSubview(toFront: self.rightView!)
        
        if controller != nil {
            controller?.removeFromParentViewController()
            controller?.view.removeFromSuperview()
        }
        
        self.airImageView?.layer.transform = CATransform3DIdentity
        self.contentView?.layer.transform = CATransform3DIdentity
        
        var leftTransform: CATransform3D = CATransform3DIdentity
        leftTransform = CATransform3DTranslate(leftTransform, kLeftViewTransX, 0, 0)
        leftTransform = CATransform3DRotate(leftTransform, AirDegreesToRadians(kLeftViewRotate), 0, 1, 0)
        self.leftView?.layer.transform = leftTransform
        
        self.rightView?.alpha = 1
        self.leftView?.alpha = 0
        
        UIView.animate(withDuration: kDuration, delay: 0, options: UIViewAnimationOptions(), animations: {[weak self]() -> Void in
            self?.leftView?.alpha = 1
            
            var airImageRotate: CATransform3D? = self?.airImageView?.layer.transform
            airImageRotate = CATransform3DRotate(airImageRotate!, AirDegreesToRadians(kAirImageViewRotate), 0, 1, 0)
            self?.airImageView?.layer.transform = airImageRotate!
            
            var rightTransform: CATransform3D? = self?.rightView?.layer.transform
            rightTransform = CATransform3DTranslate(rightTransform!, kRightViewTransX, 0, kRightViewTransZ)
            self?.rightView?.layer.transform = rightTransform!
            
            var leftTransform: CATransform3D? = self?.leftView?.layer.transform
            leftTransform = CATransform3DRotate(leftTransform!, AirDegreesToRadians(-kLeftViewRotate), 0, 1, 0)
            leftTransform = CATransform3DTranslate(leftTransform!, -kLeftViewTransX , 0, 0)
            self?.leftView?.layer.transform = leftTransform!
            
            return
            }, completion: {(finished: Bool) -> Void in
                if let com = complete {
                    com()
                }
        })
        
        self.airImageView?.tag = 1
    }
    
    open func switchToViewController(_ controller: UIViewController, atIndexPath: IndexPath) {
        self.bringViewControllerToTop(controller, indexPath: atIndexPath)
    }
    
    open func switchToViewController(_ controller: UIViewController) {
        self.bringViewControllerToTop(controller, indexPath: kIndexPathOutMenu)
    }
    
    open func hideAirViewOnComplete(_ complete: (() -> Void)?) {
        if let willHide: () = self.delegate?.willHideAirViewController?() {
            willHide
        }
        
        UIView.animate(withDuration: kDuration, delay: 0, options: UIViewAnimationOptions(), animations: {[weak self]() -> Void in
                self?.leftView?.alpha = 0
            
                var airImageRotate: CATransform3D? = self?.airImageView?.layer.transform
                airImageRotate = CATransform3DRotate(airImageRotate!, AirDegreesToRadians(-kAirImageViewRotate), 0, 1, 0)
                self?.airImageView?.layer.transform = airImageRotate!
            
                var rightTransform: CATransform3D? = self?.rightView?.layer.transform
                rightTransform = CATransform3DTranslate(rightTransform!, -kRightViewTransX, 0, -kRightViewTransZ)
                self?.rightView?.layer.transform = rightTransform!
 
                var leftTransform: CATransform3D? = self?.leftView?.layer.transform
                leftTransform = CATransform3DRotate(leftTransform!, AirDegreesToRadians(kLeftViewRotate), 0, 1, 0)
                leftTransform = CATransform3DTranslate(leftTransform!, kLeftViewTransX, 0, 0)
                self?.leftView?.layer.transform = leftTransform!
            
            }, completion: {(finished: Bool) -> Void in
                self.leftView?.alpha = 0
                self.rightView?.alpha = 0
                
                self.leftView?.layer.transform = CATransform3DIdentity
                
                if let didHide: () = self.delegate?.didHideAirViewController?() {
                    didHide
                }
                if let com = complete {
                    com()
                }
        })

        self.airImageView?.tag = 0
    }

    //MARK: Animation
    
    open func setupAnimation() {
        var rotationAndPerspectiveTransform: CATransform3D = CATransform3DIdentity
        rotationAndPerspectiveTransform.m34 = 1.0 / -600
        
        self.rightView?.layer.sublayerTransform = rotationAndPerspectiveTransform

        let anchorPoint: CGPoint = CGPoint(x: 1, y: 0.5)
        let newX: CGFloat = self.airImageView!.width * anchorPoint.x
        let newY: CGFloat = self.airImageView!.height * anchorPoint.y
        self.airImageView!.layer.position = CGPoint(x: newX, y: newY)
        self.airImageView!.layer.anchorPoint = anchorPoint
        
        self.contentView?.layer.sublayerTransform = rotationAndPerspectiveTransform
        let anchorPoint2: CGPoint = CGPoint(x: 1, y: 0.5)
        let newX2: CGFloat = self.rightView!.width * anchorPoint2.x
        let newY2: CGFloat = self.rightView!.height * anchorPoint2.y
        self.rightView!.layer.position = CGPoint(x: newX2, y: newY2)
        self.rightView!.layer.anchorPoint = anchorPoint2
        
        let leftAnchorPoint: CGPoint = CGPoint(x: -3, y: 0.5)
        let newLeftX: CGFloat = self.leftView!.width * leftAnchorPoint.x
        let newLeftY: CGFloat = self.leftView!.height * leftAnchorPoint.y
        self.leftView!.layer.position = CGPoint(x: newLeftX, y: newLeftY)
        self.leftView!.layer.anchorPoint = leftAnchorPoint
        
        let anchorPoint3: CGPoint = CGPoint(x: 1, y: 0.5)
        let newX3: CGFloat = self.contentView!.width * anchorPoint3.x
        let newY3: CGFloat = self.contentView!.height * anchorPoint3.y
        self.contentView!.layer.position = CGPoint(x: newX3, y: newY3)
        self.contentView!.layer.anchorPoint = anchorPoint3
    }
    
    //MARK: Helper
    
    open func getThumbnailForIndexPath(_ indexPath: IndexPath) -> UIImage? {
        let thumbnailDic: Dictionary = self.thumbnailImages![indexPath.section]
        if let tDic = thumbnailDic[indexPath.row] {
            return tDic
        } else {
            if let th = self.dataSource?.thumbnailImageAtIndexPath?(indexPath) {
                return th
            } else {
                return nil
            }
        }
    }
    
    open func saveThumbnailImage(_ image: UIImage?, atIndexPath indexPath: IndexPath) {
        if image == nil {
            return
        }
        
        var thumbnailDic: Dictionary = self.thumbnailImages![indexPath.section]
        thumbnailDic[indexPath.row] = image!
    }
    
    open func getViewControllerAtIndexPath(_ indexPath: IndexPath) -> UIViewController? {
        let viewControllerDic: Dictionary = self.viewControllers![indexPath.section]
        if let vDic = viewControllerDic[indexPath.row] {
            return vDic
        } else {
            return self.dataSource?.viewControllerForIndexPath!(indexPath)
        }
    }
    
    open func saveViewControler(_ controller: UIViewController?, atIndexPath indexPath: IndexPath) {
        if controller == nil {
            return
        }
        
        var viewControllerDic: Dictionary? = self.viewControllers?[indexPath.section]
        if viewControllerDic != nil {
            viewControllerDic![indexPath.row] = controller
        }
    }
    
    open func imageWithView(_ view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
    
    open func duplicate(_ view: UIView) -> UIView? {
        let tempArchive: Data = NSKeyedArchiver.archivedData(withRootObject: view)
        return NSKeyedUnarchiver.unarchiveObject(with: tempArchive) as? AirbnbSessionView
    }
    
    deinit {
        self.airImageView?.removeFromSuperview()
        self.airImageView = nil
        self.rightView?.removeFromSuperview()
        self.rightView = nil
        self.leftView?.removeFromSuperview()
        self.leftView = nil
        self.wrapperView?.removeFromSuperview()
        self.wrapperView = nil
        self.rowsOfSession = nil
    }
}

public var SwipeTagHandle = "SWIPE_HANDER"
public var SwipeObject = "SWIPE_OBJECT"

public extension UIViewController {
    
    
    typealias returnHandler = () -> Void
    
    public func usingAnyObjectWrapper(object: Any) -> returnHandler {
        return object as! returnHandler
    }
    
    public var airSwipeGestureRecognizer: UISwipeGestureRecognizer? {
        get {
            var swipe: UISwipeGestureRecognizer? = objc_getAssociatedObject(self, &SwipeObject) as? UISwipeGestureRecognizer
            if let sw = swipe {
                return sw
            } else {
                swipe = UISwipeGestureRecognizer(target: self, action: #selector(UIViewController.swipeHandler))
                swipe?.direction = UISwipeGestureRecognizerDirection.right
                objc_setAssociatedObject(self, &SwipeObject, swipe, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return swipe
            }
            
        }
    }
    
    public var airSwipeHandler: returnHandler? {
        get {
            // AnyObject -> id -> airHandler
            return usingAnyObjectWrapper(object: objc_getAssociatedObject(self, &SwipeTagHandle))
        }
        set {
            if let obj: returnHandler = newValue {
                if let view = self.airSwipeGestureRecognizer?.view {
                    view.removeGestureRecognizer(self.airSwipeGestureRecognizer!)
                }
                
                if let nv = self.navigationController {
                    nv.view.addGestureRecognizer(self.airSwipeGestureRecognizer!)
                } else {
                    self.view.addGestureRecognizer(self.airSwipeGestureRecognizer!)
                }
                // airHandler -> id -> AnyObject
                objc_setAssociatedObject(self, &SwipeTagHandle, obj as Any, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                if self.airSwipeGestureRecognizer?.view != nil {
                    self.airSwipeGestureRecognizer?.view?.removeGestureRecognizer(self.airSwipeGestureRecognizer!)
                }
                if let ph = self.airSwipeGestureRecognizer?.view {
                    ph.removeGestureRecognizer(self.airSwipeGestureRecognizer!)
                }
            }
        }
    }
    
    public var airViewController: AirbnbViewController {
        get {
            var currentVC = self
            while let parentVC = currentVC.parent {
                if let result = parentVC as? AirbnbViewController {
                    return result
                }
                currentVC = parentVC
            }
            fatalError("couldn't find AirbnbViewController in hierarchy")
        }
    }
    
    public func swipeHandler() {
        if let handler: returnHandler = self.airSwipeHandler {
            handler()
        }
    }
}

//MARK: EXtension UIView

public extension UIView {
    
    public var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var frame: CGRect = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    public var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var frame: CGRect = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    public var right: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
        set {
            var frame: CGRect = self.frame
            frame.origin.x = newValue - frame.size.width
            self.frame = frame
        }
    }
    
    public var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
        set {
            var frame: CGRect = self.frame
            frame.origin.y = newValue - frame.size.height
            self.frame = frame
        }
    }
    
    public var centerX: CGFloat {
        get {
            return self.center.x
        }
        set {
            self.center = CGPoint(x: newValue, y: self.center.y)
        }
    }
    
    public var centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            self.center = CGPoint(x: self.center.x, y: newValue)
        }
    }
    
    public var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var frame: CGRect = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    public var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var frame: CGRect = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    public var ttScreenX: CGFloat {
        get {
            var x: CGFloat = 0
            let view: UIView? = self
            
            if view?.superview != nil {
                x += view!.left
            }
            return x
        }
    }
    
    public var ttScreenY: CGFloat {
        get {
            var y: CGFloat = 0
            let view: UIView? = self
            if view?.superview != nil {
                y += view!.top
            }
            return y
        }
    }
    
    public var screenViewX: CGFloat {
        get {
            var x: CGFloat = 0
            let view: UIView? = self
            if view?.superview != nil {
                x += view!.left
                if view!.isKind(of: UIScrollView.self) {
                    let scrollView: UIScrollView = view as! UIScrollView
                    x -= scrollView.contentOffset.x
                }
            }
            return x
        }
    }
    
    public var screenViewY: CGFloat {
        get {
            var y: CGFloat = 0
            let view: UIView? = self
            if view?.superview != nil {
                y += view!.top
                if view!.isKind(of: UIScrollView.self) {
                    let scrollView: UIScrollView = view as! UIScrollView
                    y -= scrollView.contentOffset.y
                }
            }
            return y
        }
    }
    
    public var screenFrame: CGRect {
        get {
            return CGRect(x: self.screenViewX, y: self.screenViewY, width: self.width, height: self.height)
        }
    }
    
    public var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            var frame: CGRect = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }
    
    public var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            var frame: CGRect = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    
    public var allSubviews: NSArray {
        get {
            let arr: NSMutableArray = []
            arr.add(self)
            for subView in self.subviews {
                arr.addObjects(from: subView.allSubviews as [AnyObject])
            }
            return arr
        }
    }
}

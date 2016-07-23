//
//  UISwipeView.swift
//  UISwipeView
//
//  Created by Steven Traversi on 6/18/16.
//  Copyright © 2016 Steven Traversi. All rights reserved.
//

import UIKit
import Cartography

public class UISwipeView: UIView {
    
    // UIView containers that are always present
    var loadedSubViews = [LoadedSubView]()
    
    // Index of view on screen
    var currentViewIndex = 1
    var nextIndex: Int { get { return (self.currentViewIndex + self.subViewContents.count + 1) % self.subViewContents.count } }
    var prevIndex: Int { get { return (self.currentViewIndex + self.subViewContents.count - 1) % self.subViewContents.count } }
    
    // UIViews to be displayed in order
    var subViewContents = [UIView]()
    
    // Called after a focus change is completed.
    // @param will be the current view index.
    public var swipeDidEnd: (Int) -> Void = { _ in }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(subviews: [UIView]) {
        super.init(frame: CGRectZero)
        self.setSubviews(subviews)
    }
    
//    override public func layoutSubviews() {
//        print("layout subviews")
//    }
    
    /* Bounds are set during the first call to layoutSubviews. Now that bounds are set,
     * setup the subviews with their constraints. */
    override public var bounds: CGRect {
        didSet {
            self.setupSubviews(self.subViewContents)
            self.addGestureRecognizers()
            self.userInteractionEnabled = true
//            print("set bounds")
        }
    }
    
    /* Sets the list of subview contents */
    public func setSubviews(subviews: [UIView]) {
        self.subViewContents = subviews
    }
    
    /* Prepare 3 subviews that will always be loaded */
    private func setupSubviews(subViews: [UIView]) {
        // create 3 subview containers
        let view1 = LoadedSubView()
        let view2 = LoadedSubView()
        let view3 = LoadedSubView()
        self.addSubview(view1)
        self.addSubview(view2)
        self.addSubview(view3)
        // constrain them, save the left-right constraints
        constrain(view1, view2, view3, self) { viewL, viewC, viewR, superview in
            viewL.size == superview.size
            viewC.size == superview.size
            viewR.size == superview.size
            view1.constraint = (viewL.left == superview.left)
            view2.constraint = (viewC.left == superview.left)
            view3.constraint = (viewR.left == superview.left)
            viewL.top == superview.top
            viewC.top == superview.top
            viewR.top == superview.top
        }
        // bounds are zero right now
        view1.constraint.constant = -self.bounds.width
        view2.constraint.constant = 0
        view3.constraint.constant = self.bounds.width
        self.sendSubviewToBack(view1)
        self.sendSubviewToBack(view3)
        self.loadedSubViews = [view1, view2, view3]
        for i in 0...2 {
            // Add content to container
            self.setLoadedSubview(i, view: self.subViewContents[i])
        }
    }
    
    /* Change the contents of the loaded subview at @param: indexInLoadedViews to @param: view */
    private func setLoadedSubview(indexInLoadedViews: Int, view: UIView) {
        // load container
        let targetSubview = self.loadedSubViews[indexInLoadedViews]
        for contentView in targetSubview.subviews {
            contentView.removeFromSuperview()
        }
        // add content to container
        targetSubview.addSubview(view)
        constrain(targetSubview, view) { parent, child in
            child.size == parent.size
            child.edges == inset(parent.edges, 0, 0, 0, 0)
        }
    }
    
    /* Change the contents of the subview in the entire subviews list */
    public func setContentSubview(index: Int, view: UIView) {
        self.subViewContents[index] = view
        // If setting a view that's currently loaded
        if [self.prevIndex, self.currentViewIndex, self.nextIndex].contains(index) {
            // UGLY. WORKS.
            self.setLoadedSubview((index - self.currentViewIndex + 1 + self.subViewContents.count) % self.subViewContents.count, view: view)
        }
    }
    
    private func animate(animations: () -> Void, completion: () -> Void) {
//        self.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.2, delay: 0.0, options: [.CurveEaseOut], animations: animations, completion: { finished in
            completion()
        })
    }
    
    /* Cycle the loaded subviews forward */
    public func next() {
        let animations: () -> Void = {
            self.loadedSubViews[1].constraint.constant = -self.frame.width
            self.loadedSubViews[2].constraint.constant = 0
            self.layoutIfNeeded()
        }
        animate(animations, completion: { () in
            self.loadedSubViews[0].constraint.constant = self.frame.width
            self.sendSubviewToBack(self.loadedSubViews[0])
            self.currentViewIndex = self.nextIndex
            self.setLoadedSubview(0, view: self.subViewContents[self.nextIndex])
            self.reIndexSubviewsBackward()
            self.swipeDidEnd(self.currentViewIndex)
        })
    }
    
    /* Cycle the loaded subviews backward */
    public func prev() {
        let animations: () -> Void = {
            self.loadedSubViews[0].constraint.constant = 0
            self.loadedSubViews[1].constraint.constant = self.frame.width
            self.layoutIfNeeded()
        }
        animate(animations, completion: { () in
            self.loadedSubViews[2].constraint.constant = -self.frame.width
            self.sendSubviewToBack(self.loadedSubViews[2])
            self.currentViewIndex = self.prevIndex
            self.setLoadedSubview(2, view: self.subViewContents[self.prevIndex])
            self.reIndexSubviewsForward()
            self.swipeDidEnd(self.currentViewIndex)
        })
    }
    
    /* Animate the subview back to the current state with no changes */
    public func remain() {
        let animations: () -> Void = {
            self.loadedSubViews[0].constraint.constant = -self.frame.width
            self.loadedSubViews[1].constraint.constant = 0
            self.loadedSubViews[2].constraint.constant = self.frame.width
            self.layoutIfNeeded()
        }
        animate(animations, completion: { () in
            self.swipeDidEnd(self.currentViewIndex)
        })
    }
    
    /* Re-order the loadedSubviews so their index matches their order (had just moved backward) */
    private func reIndexSubviewsBackward() {
        let temp = self.loadedSubViews[0]
        self.loadedSubViews[0] = self.loadedSubViews[1]
        self.loadedSubViews[1] = self.loadedSubViews[2]
        self.loadedSubViews[2] = temp
    }
    /* Re-order the loadedSubviews so their index matches their order (had just moved forward) */
    private func reIndexSubviewsForward() {
        let temp = self.loadedSubViews[2]
        self.loadedSubViews[2] = self.loadedSubViews[1]
        self.loadedSubViews[1] = self.loadedSubViews[0]
        self.loadedSubViews[0] = temp
    }
    
    private func addGestureRecognizers() {
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        self.addGestureRecognizer(swipeGesture)
    }
    
    internal func didPan(sender: UIPanGestureRecognizer) {
        if sender.state == .Changed {
            let deltaX = sender.translationInView(self).x
            self.loadedSubViews[0].constraint.constant = -self.frame.width + deltaX
            self.loadedSubViews[1].constraint.constant = deltaX
            self.loadedSubViews[2].constraint.constant = self.frame.width + deltaX
        } else if sender.state == .Ended {
            let velocityX = sender.velocityInView(self).x
            let deltaX = sender.translationInView(self).x
            if velocityX > 100.0 {
                self.prev()
            } else if velocityX < -100.0 {
                self.next()
            } else if deltaX > self.frame.width / 2 {
                self.prev()
            } else if deltaX < -self.frame.width / 2 {
                self.next()
            } else {
                remain()
            }
        }
    }
    
    /* A UIView that carries an important constraint with it. */
    public class LoadedSubView: UIView {
        
        public var constraint: NSLayoutConstraint!
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public init() {
            super.init(frame: CGRectZero)
        }
    
    }
    
}

//
//  ViewController.swift
//  UISwipeView
//
//  Created by Steven Traversi on 6/18/16.
//  Copyright © 2016 Steven Traversi. All rights reserved.
//

import UIKit
import Cartography

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var fourthViewLoaded = false
    
    func setup() {
        let view1 = UIView()
        let view2 = UIView()
        let view3 = UIView()
        let view4 = UIView()
        view1.backgroundColor = UIColor.blueColor()
        view2.backgroundColor = UIColor.yellowColor()
        view3.backgroundColor = UIColor.redColor()
        view4.backgroundColor = UIColor.greenColor()
        let contentViews = [view1, view2, view3, UIView()]
//        let contentViews = [view1, view2, view3]
        let swipeView = UISwipeView(subviews: contentViews)
        self.view.addSubview(swipeView)
        constrain(swipeView) { swipe in
            swipe.height == 200
            swipe.leading == swipe.superview!.leading
            swipe.trailing == swipe.superview!.trailing
            swipe.top == swipe.superview!.top
        }
        swipeView.swipeDidEnd = { chartIndex in
            print(chartIndex)
            if (chartIndex + 4 - 1) % 4 == 3 || (chartIndex + 4 + 1) % 4 == 3 && !self.fourthViewLoaded {
                swipeView.setContentSubview(3, view: view4)
                self.fourthViewLoaded = true
            }
        }
        
        let prevButton = UIButton()
        prevButton.backgroundColor = .greenColor()
        prevButton.setTitle("prev", forState: .Normal)
        prevButton.addTarget(swipeView, action: #selector(swipeView.prev), forControlEvents: .TouchUpInside)
        self.view.addSubview(prevButton)
        
        let nextButton = UIButton()
        nextButton.backgroundColor = .greenColor()
        nextButton.setTitle("next", forState: .Normal)
        nextButton.addTarget(swipeView, action: #selector(swipeView.next), forControlEvents: .TouchUpInside)
        self.view.addSubview(nextButton)
        
        constrain(prevButton, nextButton, swipeView) { prev, next, swipe in
            prev.leading == swipe.leading
            next.leading == prev.trailing
            prev.top == swipe.bottom
            next.centerY == prev.centerY
            prev.height == 50
            next.height == prev.height
            prev.width == 50
            next.width == prev.width
        }
    }

}


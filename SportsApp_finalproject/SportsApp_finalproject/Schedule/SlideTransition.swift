//
//  SlideTransition.swift
//  SportsApp_finalproject
//
//  Created by Doherty, Benjamin J on 12/5/19.
//  Copyright © 2019 Doan, Douglas T. All rights reserved.
//

import UIKit

extension UIView {

    func slideInFromLeft(_ duration: TimeInterval = 1, endProgress: Float = 0.2, completionDelegate: CAAnimationDelegate? = nil) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided
        if let delegate: CAAnimationDelegate = completionDelegate {
            slideInFromLeftTransition.delegate = delegate
        }
        
        // Customize the animation's properties
        slideInFromLeftTransition.type = CATransitionType.push
        slideInFromLeftTransition.endProgress = 1.0
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromLeft
        slideInFromLeftTransition.endProgress = endProgress
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.backwards

        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
    
    func slideInFromRight(_ duration: TimeInterval = 1, endProgress: Float = 0.2, completionDelegate: CAAnimationDelegate? = nil) {

        let slideInFromLeftTransition = CATransition()

        if let delegate: CAAnimationDelegate = completionDelegate {
            slideInFromLeftTransition.delegate = delegate
        }
        
        slideInFromLeftTransition.type = CATransitionType.push
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromRight
        slideInFromLeftTransition.endProgress = endProgress
        slideInFromLeftTransition.duration = duration
        //slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        //slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed
        
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
    
    
}


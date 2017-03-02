//
//  Animate.swift
//  BeeKey
//
//  Created by Kirill on 24.02.17.
//  Copyright © 2017 Kirill. All rights reserved.
//
import UIKit
import Jelly


class Animation{
    
    func animated_transitions(viewIndefiner: String, duration: Float, type: String, subtype: String, view: UIView) -> UIViewController{
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: viewIndefiner)
        let transition = CATransition()
        transition.duration = CFTimeInterval(duration)
        transition.type = type
        transition.subtype = subtype
        view.window!.layer.add(transition, forKey: kCATransition)
        
        return resultViewController
    }
    
    func animate_swipe(idefiner: String, presentationStyle: Int, transitionStyle: Int ) -> UIViewController{
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: idefiner)
        resultViewController.modalPresentationStyle = UIModalPresentationStyle(rawValue: presentationStyle)!
        resultViewController.modalTransitionStyle = UIModalTransitionStyle(rawValue: transitionStyle)!
        
        return resultViewController
    }
    
    func backgroundImage() -> UIImageView{
        let backgroundImage = UIImage(named: "tableBackground")
        let imageView = UIImageView(image: backgroundImage)
        
        return imageView
    }
    
    func animate_alert(alert: UIAlertController){
        let customPresentation = JellySlideInPresentation(dismissCurve: .linear,
                                                          presentationCurve: .linear,
                                                          cornerRadius: 15,
                                                          backgroundStyle: .blur(effectStyle: .light),
                                                          jellyness: .jellier,
                                                          duration: .slow,
                                                          directionShow: .top,
                                                          directionDismiss: .bottom,
                                                          widthForViewController: .fullscreen,
                                                          heightForViewController: .fullscreen,
                                                          horizontalAlignment: .center,
                                                          verticalAlignment: .center,
                                                          marginGuards: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10),
                                                          corners: [.topLeft,.bottomRight])
        let jellyAnimator = JellyAnimator(presentation: customPresentation)
        jellyAnimator.prepare(viewController: alert)
        
    }
    
}

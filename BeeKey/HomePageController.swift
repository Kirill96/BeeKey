//
//  HomePageController.swift
//  BeeKey
//
//  Created by Kirill on 22.02.17.
//  Copyright © 2017 Kirill. All rights reserved.
//

import UIKit

class HomePageController: UIViewController {
    
    private let animation = Animation()
    
    @IBAction func signInPerform(_ sender: UIButton) {
        self.present(animation.animated_transitions(viewIndefiner: "signIn", duration: 0.5, type: kCATransitionPush, subtype: kCATransitionFromRight, view: view), animated:false, completion:nil)
    }
    
    @IBAction func registration(_ sender: UIButton) {
        self.present(animation.animated_transitions(viewIndefiner: "registration", duration: 0.5, type: kCATransitionPush, subtype: kCATransitionFromTop, view: view), animated:false, completion:nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

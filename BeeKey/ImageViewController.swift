//
//  ImageViewController.swift
//  BeeKey
//
//  Created by Kirill on 23.02.17.
//  Copyright © 2017 Kirill. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    
    private var icon = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func touchIcon(_ sender: UIButton) {
        icon = sender.currentTitle!
        let setimage = parent as! AddOrEditTableViewController
        setimage.SetImage(icon)
        
    }
    
}

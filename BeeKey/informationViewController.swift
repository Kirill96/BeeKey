//
//  informationTableViewController.swift
//  BeeKey
//
//  Created by Kirill on 24.01.17.
//  Copyright © 2017 Kirill. All rights reserved.
//

import UIKit
import RealmSwift

class informationTableViewController: UITableViewController {
    
    @IBOutlet weak var key_name: UILabel!
    @IBOutlet weak var site: UILabel!
    @IBOutlet weak var login: UILabel!
    @IBOutlet weak var password: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    
    let key_encrypt = "bbC2H19lkVbQDfakxcrtNMQdd0FloLyw"
    let iv = "gqLOHUioQ0QjhuvI"
    
    private let animation = Animation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(informationTableViewController.swiped(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        self.tableView.backgroundView = animation.backgroundImage()
        
        let realm = try! Realm()
        let key = realm.objects(Keys.self).filter("activity == true").first
        
        key_name.text = key!.key_name
        site.text = key!.site
        login.text = key!.login
        password.text = try! key!.password.decrypt(key_encrypt, iv)
        photoImage.image = UIImage(named: key!.image)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let translationTransform = CATransform3DTranslate(CATransform3DIdentity, -500, 400, 0)
        cell.layer.transform = translationTransform
        cell.backgroundColor = .clear
        
        UIView.animate(withDuration: 1, delay: 0.1 * Double(indexPath.row), options: .curveEaseInOut, animations: {
            cell.layer.transform = CATransform3DIdentity
        })
    }
    
    @IBAction func Cancel(_ sender: UIBarButtonItem) {
        deactive()
        self.present(animation.animated_transitions(viewIndefiner: "TableLeyController", duration: 0.5, type: kCATransitionPush, subtype: kCATransitionFromLeft, view: view), animated:false, completion:nil)
    }
    
    func swiped(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                self.present(animation.animated_transitions(viewIndefiner: "TableLeyController", duration: 0.5, type: kCATransitionPush, subtype: kCATransitionFromLeft, view: view), animated:false, completion:nil)
                deactive()
            default:
                break
            }
        }
    }
    
    private func deactive(){
        let realm = try! Realm()
        let key = realm.objects(Keys.self).filter("activity == true").first
        
        try! realm.write {
            key!.activity = false
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

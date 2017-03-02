//
//  NavigationController.swift
//  BeeKey
//
//  Created by Kirill on 23.01.17.
//  Copyright © 2017 Kirill. All rights reserved.
//

import UIKit
import RealmSwift
import Jelly

class NavigationController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let animation = Animation()
    
    var search_key = try! Realm().objects(Keys.self)
    var searchActive : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.backgroundView = animation.backgroundImage()
    }
    
    @IBAction func Exit(_ sender: UIBarButtonItem) {
        let realm = try! Realm()
        let user = realm.objects(Users.self).filter("state == true").first
        
        try! realm.write {
            user!.state = false
        }
        
        self.present(animation.animate_swipe(idefiner: "HomeController", presentationStyle: 2, transitionStyle: 1), animated:true, completion:nil)
    }
    
    @IBAction func tap_searchBar(_ sender: Any) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive{
            return search_key.count
        }else{
            let realm = try! Realm()
            let key = realm.objects(Keys.self).filter("user.state == true")
            
            return key.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        if(searchActive){
            cell.keyImageView?.image = UIImage(named: search_key[indexPath.row].image)
            cell.keyNameLabel?.text = search_key[indexPath.row].key_name
            cell.loginLabel?.text = search_key[indexPath.row].login
        }else if(search_key.count == 0){
            cell.keyImageView?.image = nil
            cell.keyNameLabel?.text = nil
            cell.loginLabel?.text = nil
            
        }else{
            let realm = try! Realm()
            let keys = realm.objects(Keys.self).filter("user.state == true")
            
            cell.keyImageView?.image = UIImage(named: keys[indexPath.row].image)
            cell.keyNameLabel?.text = keys[indexPath.row].key_name
            cell.loginLabel?.text = keys[indexPath.row].login
            cell.keyImageView.layer.cornerRadius = 30.0
            cell.keyImageView.clipsToBounds = true
        }
        
        cell.keyImageView?.layer.cornerRadius = 30.0
        cell.keyImageView?.clipsToBounds = true
        
        return cell
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        
        let optionMenu = UIAlertController(title: nil, message: "Choose your action", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let informationActionHandler = { (action: UIAlertAction!) -> Void in
            
            self.activity_key(self.search_key, self.searchActive, indexPath.row)
            
            self.performSegue(withIdentifier: "showInform", sender: self)
            
        }
        
        let editActionHandler = { (action: UIAlertAction!) -> Void in
            self.activity_key(self.search_key, self.searchActive, indexPath.row)
            self.performSegue(withIdentifier: "showAddForm", sender: self)
            
        }
        
        let safariActionHandler = { (action: UIAlertAction!) -> Void in
            let realm = try! Realm()
            let keys = realm.objects(Keys.self).filter("user.state == true")
            
            if self.can_open_url(string: keys[indexPath.row].site){
                UIApplication.shared.open(URL(string: keys[indexPath.row].site)!, options: [:], completionHandler: nil)
            }else{
                let alertMessage = UIAlertController(title: "Safari", message: "Not a valid url", preferredStyle: .alert)
                
                self.animation.animate_alert(alert: alertMessage)
                alertMessage.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertMessage, animated: true, completion: nil)
            }
        }
        
        let safariAction = UIAlertAction(title: "Open in Safari", style: .default, handler: safariActionHandler)
        
        let informationAction = UIAlertAction(title: "Information", style: .default, handler: informationActionHandler)
        let editAction = UIAlertAction(title: "Edit", style: .default, handler: editActionHandler)
        
        optionMenu.addAction(safariAction)
        optionMenu.addAction(editAction)
        optionMenu.addAction(cancelAction)
        optionMenu.addAction(informationAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (actin, indexPath) -> Void in
            
            let realm = try! Realm()
            if(self.searchActive){
                try! realm.write {
                    realm.delete(self.search_key[indexPath.row])
                }
            }else{
                let keys = realm.objects(Keys.self).filter("user.state == true")
                try! realm.write {
                    realm.delete(keys[indexPath.row])
                }
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            
        })
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let degree: Double = 90
        let rotationAngle = CGFloat(degree * M_PI / 180)
        let rotationTransform = CATransform3DMakeRotation(rotationAngle, 1, 0, 0)
        cell.layer.transform = rotationTransform
        cell.backgroundColor = .clear
        
        UIView.animate(withDuration: 1, delay: 0.05 * Double(indexPath.row), options: .curveEaseInOut, animations: {
            cell.layer.transform = CATransform3DIdentity
        })
    }
    
    private func activity_key<T: Equatable>(_ object: T, _ check: Bool, _ index: Int) {
        let realm = try! Realm()
        if(check){
            let realm = try! Realm()
            try! realm.write {
                self.search_key[index].activity = true
            }
        }else{
            let keys = realm.objects(Keys.self).filter("user.state == true")
            try! realm.write {
                keys[index].activity = true
            }
        }
        
    }
    
    func can_open_url(string: String?) -> Bool {
        guard let urlString = string else {return false}
        guard let url = NSURL(string: urlString) else {return false}
        if !UIApplication.shared.canOpenURL(url as URL) {return false}
        
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let realm = try! Realm()
        
        let predicate = NSPredicate(format: "key_name BEGINSWITH [c]%@", searchText)
        
        search_key = realm.objects(Keys.self).filter(predicate).filter("user.state == true")
        
        if(search_key.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        tableView.reloadData()
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
}

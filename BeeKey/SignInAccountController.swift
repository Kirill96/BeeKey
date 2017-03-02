//
//  SignInAccountController.swift
//  BeeKey
//
//  Created by Kirill on 21.01.17.
//  Copyright © 2017 Kirill. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyButton

class SignInAccountController: UIViewController {
    
    @IBOutlet weak var userLogin: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var ErrorLabel: UITextField!
    @IBOutlet weak var customButton: UIButton!
    
    let key_encrypt = "bbC2H19lkVbQDfakxcrtNMQdd0FloLyw"
    let iv = "gqLOHUioQ0QjhuvI"
    
    private var users: Users!
    private let animation = Animation()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let buttonNext = PressableButton()
        customButton.addSubview(buttonNext)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignInAccountController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignInAccountController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func swiped(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                self.present(animation.animated_transitions(viewIndefiner: "HomeController", duration: 0.7, type: kCATransitionPush, subtype: kCATransitionFromLeft, view: view), animated:false, completion:nil)
            default:
                break
            }
        }
    }
    
    @IBAction func signInAcount(_ sender: UIButton) {
        if (validateFields()){
            if readUser(){
                self.present(animation.animate_swipe(idefiner: "TableLeyController", presentationStyle:
                    0, transitionStyle: 1), animated:true, completion:nil)
            }else{
                ErrorLabel.text = "Incorrect login or password"
            }
        }else{
            ErrorLabel.text = "Empty field login or password"
        }
    }
    
    private func readUser() -> Bool{
        let users = try! Realm().objects(Users.self)
        for user in users{
            if user.login == userLogin.text! && (try!user.password.decrypt(key_encrypt, iv) == userPassword.text!){
                let realm = try! Realm()
                try! realm.write {
                    user.state = true
                }
                return true
            }
        }
        return false
    }
    
    private func validateFields() -> Bool {
        if !(userLogin.text!.isEmpty || userPassword.text!.isEmpty) {
            return true
        }
        return false
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if userLogin.isEditing || userPassword.isEditing {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0{
                    self.view.frame.origin.y -= 2*keyboardSize.height/3
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as?  NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += 2*keyboardSize.height/3
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        userLogin.resignFirstResponder()
        userPassword.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

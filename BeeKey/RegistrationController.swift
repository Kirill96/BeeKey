//
//  RegistrationController.swift
//  BeeKey
//
//  Created by Kirill on 18.01.17.
//  Copyright © 2017 Kirill. All rights reserved.
//

import UIKit
import RealmSwift
import CryptoSwift
import Jelly

class RegistrationController: UIViewController, UITextFieldDelegate{
    
    
    @IBOutlet weak var vissible_password: UISwitch!
    @IBOutlet weak var vissible_confirm_password: UISwitch!
    @IBOutlet weak var ErrorName: UILabel!
    @IBOutlet weak var ErrorConfirmPassword: UILabel!
    @IBOutlet weak var ErrorPassword: UILabel!
    @IBOutlet weak var ErrorLogin: UILabel!
    @IBOutlet weak var ErrorSurname: UILabel!
    @IBOutlet private weak var userName: UITextField!
    @IBOutlet private weak var userSurname: UITextField!
    @IBOutlet private weak var userLogin: UITextField!
    @IBOutlet private weak var userPassword: UITextField!
    @IBOutlet private weak var userConfirmPassword: UITextField!
    
    let key_encrypt = "bbC2H19lkVbQDfakxcrtNMQdd0FloLyw"
    let iv = "gqLOHUioQ0QjhuvI"
    
    private var users: Users!
    private let animation = Animation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(RegistrationController.swiped(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        userName.resignFirstResponder()
        userSurname.resignFirstResponder()
        userLogin.resignFirstResponder()
        userPassword.resignFirstResponder()
        userConfirmPassword.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.present(animation.animated_transitions(viewIndefiner: "HomeController", duration: 0.5, type: kCATransitionPush, subtype: kCATransitionFromLeft, view: view), animated:false, completion:nil)
    }
    
    @IBAction func registerNewUser(_ sender: UIButton) {
        if validateFields() {
            if (addNewUser()){
                self.present(animation.animated_transitions(viewIndefiner: "signIn", duration: 0.5, type: kCATransitionPush, subtype: kCATransitionFromBottom, view: view), animated:false, completion:nil)
            }
        }
    }
    
    
    @IBAction func on_of_security_password(_ sender: Any) {
        if (vissible_password.isOn){
            userPassword.isSecureTextEntry = false
        }else{
            userPassword.isSecureTextEntry = true
        }
    }
    
    @IBAction func on_of_security_confirm_password(_ sender: Any) {
        if (vissible_confirm_password.isOn){
            userConfirmPassword.isSecureTextEntry = false
        }else{
            userConfirmPassword.isSecureTextEntry = true
        }
    }
    
    func swiped(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                self.present(animation.animated_transitions(viewIndefiner: "HomeController", duration: 0.5, type: kCATransitionPush, subtype: kCATransitionFromLeft, view: view), animated:false, completion:nil)
            default:
                break
            }
        }
    }
    
    private func addNewUser() -> Bool {
        let realm = try! Realm()
        
        try! realm.write {
            let newUser = Users()
            
            newUser.name = self.userName.text!
            newUser.surname = self.userSurname.text!
            newUser.login = self.userLogin.text!
            newUser.password = try! self.userPassword.text!.encrypt(key_encrypt, iv)!
            
            realm.add(newUser)
            self.users = newUser
        }
        return true
    }
    
    private func validateFields() -> Bool {
        
        if userName.text!.isEmpty || userSurname.text!.isEmpty ||
            userLogin.text!.isEmpty || userPassword.text!.isEmpty ||
            userConfirmPassword.text!.isEmpty {
            
            
            let alertController = UIAlertController(title: "Validation Error", message: "All fields must be filled", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive) { alert in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            animation.animate_alert(alert: alertController)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
            
            return false
            
        } else {
            if userName.text!.isValidName_Surname() && userSurname.text!.isValidName_Surname() && userLogin.text!.isValidLogin() && userPassword.text!.isValidPassword() && checkRepeatLogin() &&
                userConfirmPassword.text! == userPassword.text!{
                return true
            }else{
                validateRegistrForm()
                return false
            }
        }
    }
    
    private func validateRegistrForm(){
        
        ErrorName.text = ""
        ErrorSurname.text = ""
        ErrorLogin.text = ""
        ErrorPassword.text = ""
        ErrorConfirmPassword.text = ""
        
        if !((userName.text!.isValidName_Surname())){
            ErrorName.text = "Incorrect Name(latin and cyrillic)"
        }
        
        if !(userSurname.text!.isValidName_Surname()){
            ErrorSurname.text = "Incorrect Surname(latin and cyrillic)"
        }
        
        if !(userPassword.text!.isValidPassword()){
            ErrorPassword.text = "Incorrect Password"
        }
        
        if !(userLogin.text!.isValidLogin()){
            ErrorLogin.text = "Incorrect Login"
        }else{
            let _ = checkRepeatLogin()
        }
        
        if !(userPassword.text! == userConfirmPassword.text){
            ErrorConfirmPassword.text = "Differences with a password"
        }
    }
    
    private func checkRepeatLogin() -> Bool{
        let users = try! Realm().objects(Users.self)
        for user in users{
            if user.login == userLogin.text!{
                ErrorLogin.text = "This login exist"
                return false
            }
        }
        return true
    }
    
    
    
    func keyboardWillShow(notification: NSNotification) {
        if userPassword.isEditing || userConfirmPassword.isEditing || userLogin.isEditing{
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as?      NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0{
                    self.view.frame.origin.y -= 4*keyboardSize.height/5
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += 4*keyboardSize.height/5
            }
        }
    }
}

extension String {
    func isValidName_Surname() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[а-яА-ЯёЁa-zA-Z]+$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }
    
    func isValidLogin() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[a-zA-Z][a-zA-Z0-9-_\\.]{1,20}$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }
    
    func isValidPassword() -> Bool{
        let regex = try? NSRegularExpression(pattern:"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }
    
    func encrypt(_ key: String, _ iv: String) throws -> String? {
        guard let data = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        let enc = try AES(key: key, iv: iv, blockMode:.CBC).encrypt(data)
        let encData = Data(bytes: enc, count: Int(enc.count))
        let base64String: String = encData.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
        let result = String(base64String)
        return result
    }
    
    func decrypt(_ key: String,_ iv: String) throws -> String? {
        guard let data = Data(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0)) else {
            return nil
        }
        let dec = try AES(key: key, iv: iv, blockMode:.CBC).decrypt(data)
        let decData = Data(bytes: dec, count: Int(dec.count))
        let result = NSString(data: decData, encoding: String.Encoding.utf8.rawValue)
        return String(result!)
    }
}

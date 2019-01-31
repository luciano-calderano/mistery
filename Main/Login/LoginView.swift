//
//  LoginView.swift
//  MysteryClient
//
//  Created by Lc on 23/04/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import UIKit

protocol LoginViewDelegate {
    func loginView (_ view: LoginView, user: String, pass: String, save: Bool)
    func loginViewSignUp (_ view: LoginView)
    func loginViewPassForgotten (_ view: LoginView)
}

class LoginView: UIView {
    class func Instance() -> LoginView {
        return InstanceView() as! LoginView
    }
    var delegate: LoginViewDelegate?
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var userView: UIView!
    @IBOutlet var passView: UIView!
    
    @IBOutlet var userText: MYTextField!
    @IBOutlet var passText: MYTextField!
    
    @IBOutlet var saveCredButton: MYButton!
    @IBOutlet private var versLabel: UILabel!

    private var checkImg: UIImage?
    private var saveCred = false
    
    //MARK:-
    
    override func awakeFromNib() {
        super.awakeFromNib()
        versLabel.text = "Vers.\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"        
        checkImg = saveCredButton.image(for: .normal)
        saveCredButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        userText.delegate = self
        passText.delegate = self
        
        userView.layer.cornerRadius = userView.frame.size.height / 2
        passView.layer.cornerRadius = passView.frame.size.height / 2
        
        saveCredButton.setImage(nil, for: .normal)
        
        let credential = User.shared.credential()
        userText.text = credential.user
        passText.text = credential.pass
        #if DEBUG
        //        userText.text = "utente_gen"; passText.text = "novella44"
        //        userText.text = "fc883"; passText.text = "mebius01"
        #endif

        saveCred = !credential.user.isEmpty
        updateCheckCredential()
    }
    
    @IBAction func saveCredTapped () {
        saveCred = !saveCred
        updateCheckCredential()
    }
    
    @IBAction func signInTapped () {
        if userText.text!.isEmpty {
            userText.becomeFirstResponder()
            return
        }
        if passText.text!.isEmpty {
            passText.becomeFirstResponder()
            return
        }
        endEditing(true)
        delegate?.loginView(self, user: self.userText.text!, pass: self.passText.text!, save: saveCred)
    }
    
    @IBAction func signUpTapped () {
        delegate?.loginViewSignUp(self)
    }
    
    @IBAction func credRecoverTapped () {
        delegate?.loginViewPassForgotten(self)
    }
    
    //MARK: - private
    
    private func updateCheckCredential() {
        let img: UIImage? = saveCred == true ? checkImg : nil
        saveCredButton.setImage(img, for: .normal)
    }
}

//MARK:- UITextFieldDelegate

extension LoginView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userText {
            passText.becomeFirstResponder()
            return true
        }
        if textField == passText {
            endEditing(true)
        }
        return true
    }
}

//
//  Login.swift
//  MysteryClient
//
//  Created by Developer on 23/01/2020.
//  Copyright © 2020 Mebius. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    @IBOutlet var containerView: UIView!
    @IBOutlet var userView: UIView!
    @IBOutlet var passView: UIView!
    
    @IBOutlet var userText: MYTextField!
    @IBOutlet var passText: MYTextField!
    
    @IBOutlet var saveCredButton: MYButton!
    @IBOutlet private var versLabel: UILabel!

    private var checkImg: UIImage?
    private var saveCred = false
    
    private let home = "https://shopper.mebius.it"
    
    //MARK:-
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        userText.text = "utente_gen";   passText.text = "novella18"
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
        view.endEditing(true)
        login()
    }
    
    @IBAction func signUpTapped () {
        let url = home + "/login/register?app=1"
        openWeb(url)
    }
    
    @IBAction func credRecoverTapped () {
        let url = home + "/login/retrieve-password/app/1"
        openWeb(url)
    }
    
    private func logged(token: String ) {
        let url = home + "?token=" + token
        openWeb(url)
    }

    //MARK: - private
    
    private func updateCheckCredential() {
        let img: UIImage? = saveCred == true ? checkImg : nil
        saveCredButton.setImage(img, for: .normal)
    }
    
    private func login() {
        User.shared.checkUser(saveCredential: saveCred,
                              userName: userText.text!,
                              password: passText.text!,
                              completion: { (token) in
                                self.logged(token: token)
                                
        }) { (errorCode, message) in
            self.alert(errorCode, message: message, okBlock: nil)
        }
    }

 
    private func openWeb(_ url: String ) {
        let web = WebAppVC.Instance()
        web.page = url
        navigationController?.show(web, sender: self)
    }
}

//MARK:- UITextFieldDelegate

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userText {
            passText.becomeFirstResponder()
            return true
        }
        if textField == passText {
            view.endEditing(true)
        }
        return true
    }
}

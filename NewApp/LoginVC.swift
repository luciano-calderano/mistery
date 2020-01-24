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
    
    private let kUser = "kUser"
    private let kPass = "kPass"
    private let home = "https://shopper.mebius.it"
    private let urlRecover = "https://mysteryclient.mebius.it/login/retrieve-password/app/1"
    private let urlSignup  = "https://mysteryclient.mebius.it/login/register?app=1"

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let cred = UserDefaults.standard
        userText.text = cred.object(forKey: kUser) as? String ?? ""
        passText.text = cred.object(forKey: kPass) as? String ?? ""
        saveCred = userText.text!.count > 0
        updateCheckCredential()

        #if DEBUG
//         userText.text = "utente_gen";   passText.text = "novella18"
        #endif
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
        
        getToken({ (token) in
            self.logged(token: token)
        })
    }
    
    @IBAction func signUpTapped () {
        openWeb(urlSignup)
    }
    
    @IBAction func credRecoverTapped () {
        openWeb(urlRecover)
    }
    
    private func logged(token: String ) {
        let cred = UserDefaults.standard
        if saveCred {
            cred.set(userText.text, forKey: kUser)
            cred.set(passText.text, forKey: kPass)
        }
        else {
            cred.set("", forKey: kUser)
            cred.set("", forKey: kPass)
        }
        let url = home + "?token=" + token
        openWeb(url)
    }

    //MARK: - private
    
    private func updateCheckCredential() {
        let img: UIImage? = saveCred == true ? checkImg : nil
        saveCredButton.setImage(img, for: .normal)
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

extension LoginVC {
    func getToken(_ completion: @escaping (String) -> ()) {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        
        let param = [
            "grant_type"    : "password",
            "client_id"     : AppConf.client_id,
            "client_secret" : AppConf.client_secret,
            "version"       : "i" + version,
            "username"      : userText.text!,
            "password"      : passText.text!,
        ]
        
        let req = MYReq(Config.Url.grant)
        req.params = param
        req.start { (response) in
            print(response)
            if response.success,
                let tokenDict = response.jsonDict["token"] as? JsonDict,
                let token = tokenDict["access_token"] as? String {
                completion(token)
                return
            }
            self.alert("Errore", message: response.errorDesc)
        }
    }
}

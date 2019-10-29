//
//  ViewController.swift
//  MysteryClient
//
//  Created by mac on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class Main: MYViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var versLabel: UILabel!
    let menuView = MenuView.Instance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Config.Path.docs)
        
        let imv = UIImageView(image: UIImage(named: "back"))
        view.addSubviewWithConstraints(imv, top: 40)
        view.sendSubviewToBack(imv)
        
        loadData()
        versLabel.text = "Vers.\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
        menuView.isHidden = true
        menuView.delegate = self
        view.addSubview(menuView)
        
        checkUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if User.shared.getUsername().isEmpty {
            return
        }
        MainOnAppear.execute()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let h = header {
            let headerRect = h.frame
            var rect = self.view.frame
            rect.origin.x = -rect.size.width
            rect.origin.y = headerRect.origin.y + headerRect.size.height
            rect.size.height -= rect.origin.y
            menuView.frame = rect
        }
    }
    
    override func headerViewSxTapped() {
        menuVisible(menuView.isHidden)
    }
    
    private func checkUser () {
        if User.shared.logged() == false {
            showLogin()
        }
    }
    
    private func showLogin () {
        let loginView = LoginView.Instance()
        view.addSubviewWithConstraints(loginView)
        loginView.delegate = self
    }
}

extension Main: UITableViewDataSource {
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MainCell.dequeue(tableView, indexPath)
        let item = dataArray[indexPath.row] as! MenuItem
        cell.title = item.type.rawValue
        return cell
    }
}

extension Main: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = dataArray[indexPath.row] as! MenuItem
        menuSelectedItem(item)
    }
}

extension Main {
    private func loadData() {
        switch AppConf.appType {
        case .MC :
            dataArray = [
                addMenuItem("ico.incarichi", type: .inca),
                addMenuItem("ico.ricInc",    type: .stor),
                addMenuItem("ico.find",      type: .find),
                addMenuItem("ico.profilo",   type: .prof),
                addMenuItem("ico.cercando",  type: .cerc),
                addMenuItem("ico.news",      type: .news),
                addMenuItem("ico.learning",  type: .lear),
            ]
        case .EA :
            dataArray = [
                addMenuItem("ico.incarichi", type: .inca),
                addMenuItem("ico.profilo",   type: .prof),
                addMenuItem("ico.news",      type: .news),
                addMenuItem("ico.learning",  type: .lear),
            ]
        }
    }
    
    private func addMenuItem (_ iconName: String, type: MenuItemEnum) -> MenuItem {
        let icon = UIImage(named: iconName)!
        let size = 24
        UIGraphicsBeginImageContext(CGSize(width: size, height: size))
        icon.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let item = MenuItem(icon: newImage, type: type)
        return item
    }
    
    private func selectedItem(_ item: MenuItem) {
        menuHide()
        
        var webType = WebPage.WebPageEnum.none
        switch item.type {
        case .inca :
            let vc = JobsHome.Instance()
            self.navigationController?.show(vc, sender: self)
            return
        case .stor :
            webType = .storico
        case .find :
            webType = .find
        case .prof :
            webType = .profile
        case .cerc :
            webType = .cercando
        case .news :
            webType = .news
        case .chat :
            webType = .chat
        case .cont :
            webType = .contattaci
        case .lear :
            webType = .learning
        case .logout :
            User.shared.logout()
            showLogin()
            return
        default:
            return
        }
        let ctrl = WebPage.Instance(type: webType)
        navigationController?.show(ctrl, sender: self)
        ctrl.title = item.type.rawValue
    }
    
    //MARK: - Menu show/hode
    
    func menuHide() {
        menuView.menuHide()
        headerTitle = Lng("home")
        header?.header.sxButton.setImage(UIImage(named: "ico.menu"), for: .normal)
    }
    
    func menuShow () {
        menuView.menuShow()
        headerTitle = Lng("menu")
        header?.header.sxButton.setImage(UIImage(named: "ico.back"), for: .normal)
    }
}

//MARK: -

extension Main: LoginViewDelegate {
    func loginView(_ view: LoginView, user: String, pass: String, save: Bool) {
        MYHud.show()
        User.shared.checkUser(saveCredential: save,
                              userName: user,
                              password: pass,
                              completion: { (redirect_url) in
                                print(redirect_url)
                                MYHud.hide()
                                view.removeFromSuperview()
                                MYJob.shared.clearJobs()
                                
                                self.sendTokenPush()
                                
        }) { (errorCode, message) in
            MYHud.hide()
            self.alert(errorCode, message: message, okBlock: nil)
        }
    }
    func loginViewSignUp(_ view: LoginView) {
        openWeb(type: .register, title: "signUp")
    }
    func loginViewPassForgotten(_ view: LoginView) {
        openWeb(type: .recover, title: "passForg")
    }
    
    private func sendTokenPush() {
        let param = [
            "object"    : "notification_token",
            "object_id" : User.shared.tokenPush
        ]
        let request = MYHttp(.put, param: param)
        request.load(ok: {
            (response) in
            print(response)
        }) {
            (errorCode, message) in
            self.alert(errorCode, message: message, okBlock: nil)
        }
        
    }
    private func openWeb (type: WebPage.WebPageEnum, title: String) {
        let ctrl = WebPage.Instance(type: type)
        navigationController?.show(ctrl, sender: self)
        ctrl.title = Lng(title)
    }
}

//MARK: -

extension Main: MenuViewDelegate {
    func menuSelectedItem(_ item: MenuItem) {
        selectedItem(item)
    }
    
    func menuVisible(_ visible: Bool) {
        if visible {
            menuShow()
        }
        else {
            menuHide()
        }
    }
}

//MARKK:- HomeCell - UITableViewCell

class MainCell: UITableViewCell {
    class func dequeue (_ tableView: UITableView, _ indexPath: IndexPath) -> MainCell {
        return tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell
    }
    
    var title = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    @IBOutlet private var titleLabel: MYLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.layer.cornerRadius = titleLabel.frame.size.height / 2
        titleLabel.layer.masksToBounds = true
        titleLabel.backgroundColor = .myGreenLight
        titleLabel.textColor = .white
    }
}



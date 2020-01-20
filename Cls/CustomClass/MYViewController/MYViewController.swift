//
//  MyViewController.swift
//
//  Created by Luciano Calderano on 26/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

class MYViewController: UIViewController, HeaderViewDelegate {
    @IBOutlet var header: HeaderContainerView?
    var dataArray = [Any]()
    var headerTitle = "" {
        didSet { header?.header.titleLabel.text = headerTitle }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        if let header = header {
            header.delegate = self
            header.header.kpiLabel.isHidden = true
        }
        MYGps.getLocation()
    }
    
    func headerViewSxTapped() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func headerViewDxTapped() {
        assertionFailure("override dx button tap")
    }
}

class MenuViewController: MYViewController {
    let menuView = MenuView.Instance()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        var rect = self.view.frame
        rect.origin.x = -rect.size.width
        rect.origin.y = (header?.frame.origin.y)! + (header?.frame.size.height)!
        rect.size.height -= rect.origin.y
        menuView.frame = rect
        menuView.isHidden = true
        menuView.delegate = self
        self.view.addSubview(menuView)
    }

    private func loadData() {
        dataArray = [
            addMenuItem("ico.incarichi", type: .inca),
            addMenuItem("ico.ricInc",    type: .stor),
            addMenuItem("ico.profilo",   type: .prof),
            addMenuItem("ico.cercando",  type: .cerc),
            addMenuItem("ico.news",      type: .news),
            addMenuItem("ico.learning",  type: .lear),
        ]
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
        case .prof :
            webType = .profile
        case .cerc :
            webType = .cercando
        case .news :
            webType = .news
        case .cont :
            webType = .contattaci
        case .lear :
            webType = .learning
        case .logout :
            User.shared.logout()
            self.navigationController?.popToRootViewController(animated: true)
            chechUser()
            return
        default:
            return
        }
        let ctrl = WebPage.Instance(type: webType)
        self.navigationController?.show(ctrl, sender: self)
        ctrl.title = item.type.rawValue
    }

    func chechUser () {
//        if User.shared.token.isEmpty {
//            let loginCtrl = LoginView.Instance()
//            self.view.addSubviewWithConstraints(loginCtrl.view)
//        }
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

extension MenuViewController: MenuViewDelegate {
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


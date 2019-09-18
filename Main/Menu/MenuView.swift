//
//  ViewController.swift
//  MysteryClient
//
//  Created by mac on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

struct MenuItem {
    var icon: UIImage!
    var type: MenuItemEnum
}

protocol MenuViewDelegate {
    func menuVisible(_ visible: Bool)
    func menuSelectedItem(_ item: MenuItem)
}

class MenuView: UIView {
    class func Instance() -> MenuView {
        return InstanceView() as! MenuView
    }

    var delegate: MenuViewDelegate?
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var backView: UIView!
    
    var dataArray = [MenuItem]()
    var currentItem = MenuItemEnum._none
    let cellId = "MenuCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)

        let tapBack = UITapGestureRecognizer(target: self, action: #selector(swipped))
        backView.addGestureRecognizer(tapBack)
        
        dataArray = [
            addMenuItem("ico.home",      type: .home),
            addMenuItem("ico.incarichi", type: .inca),
            addMenuItem("ico.ricInc",    type: .stor),
            addMenuItem("ico.find",      type: .find),
            addMenuItem("ico.profilo",   type: .prof),
            addMenuItem("ico.cercando",  type: .cerc),
            addMenuItem("ico.news",      type: .news),
            addMenuItem("ico.mail",      type: .cont),
            addMenuItem("ico.chat",      type: .chat),
            addMenuItem("ico.logout",    type: .logout),
        ]
    }
    
    private func addMenuItem (_ iconName: String, type: MenuItemEnum) -> MenuItem {
        let icon = UIImage(named: iconName)!.resize(24)
        let item = MenuItem(icon: icon, type: type)
        return item
    }

    @objc func swipped () {
        menuHide()
        delegate?.menuVisible(false)
    }
    
    func menuHide () {
        UIView.animate(withDuration: 0.2, animations: {
            var rect = self.frame
            rect.origin.x = -rect.size.width
            self.frame = rect
        }) { (true) in
            self.isHidden = true
        }
    }

    func menuShow () {
        isHidden = false
        UIView.animate(withDuration: 0.5,
                                   delay: 0,
                                   usingSpringWithDamping: 0.6,
                                   initialSpringVelocity: 0.1,
                                   options: .curveEaseInOut,
                                   animations: {
            var rect = self.frame
            rect.origin.x = 0
            self.frame = rect
        })
    }
}

// MARK:- UITableViewDataSource

extension MenuView: UITableViewDataSource {
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as UITableViewCell

        let item = dataArray[indexPath.row]
        cell.imageView!.image = item.icon
        cell.textLabel?.text = item.type.rawValue
        cell.textLabel?.font = UIFont.size(14)
        cell.backgroundColor = (item.type == currentItem) ? .lightGray : .white
        return cell
    }
}

// MARK:- UITableViewDelegate

extension MenuView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = dataArray[indexPath.row]
        delegate?.menuSelectedItem(item)
    }
}

//
//  JobDetailAtch
//  MysteryClient
//
//  Created by mac on 28/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

protocol JobDetailAtchDelegate {
    func openFileFromUrlWithString (_ page: String)
}

class JobDetailAtch: UIView, UITableViewDelegate, UITableViewDataSource {
    class func Instance() -> JobDetailAtch {
        return InstanceView() as! JobDetailAtch
    }
    
    var delegate: JobDetailAtchDelegate?
    
    @IBOutlet private var tableView: UITableView!
    private let cellId = "cellId"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellId)
    }
    
    @IBAction func okTapped () {
        self.removeFromSuperview()
    }
    
    // MARK:- table view
    
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Current.job.attachments.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
            cell?.textLabel?.textColor = .darkGray
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        }

        let item = Current.job.attachments[indexPath.row]
        cell?.imageView?.image = UIImage(named: "ico.download")?.resize(16)
        cell?.textLabel?.text = item.name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = Current.job.attachments[indexPath.row]
        self.delegate?.openFileFromUrlWithString(item.url + "/" + item.filename)
    }
}

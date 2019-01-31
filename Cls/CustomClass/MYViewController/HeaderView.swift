//
//  HeaderView
//  Kanito
//
//  Created by Luciano Calderano on 17/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

public protocol HeaderViewDelegate: class {
    func headerViewSxTapped()
    func headerViewDxTapped()
}

class HeaderContainerView : UIView, HeaderViewDelegate {
    weak var delegate:HeaderViewDelegate?
    let header = HeaderView.Instance()
    
    @IBInspectable var title:String = ""
    @IBInspectable var sxImage: UIImage?
    @IBInspectable var dxImage: UIImage?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }
    
    func initialize() {
        self.addSubview(header)
        header.delegate = self
        header.frame = self.bounds
        header.backgroundColor = self.backgroundColor
        header.titleLabel.text = self.title.toLang()

        if self.sxImage == nil {
            header.sxButton.isHidden = true
        }
        else {
            header.sxButton.isHidden = false
            header.sxButton.setImage(self.sxImage, for: .normal)
        }

        if self.dxImage == nil {
            header.dxButton.isHidden = true
        }
        else {
            header.dxButton.isHidden = false
            header.dxButton.setImage(self.dxImage, for: .normal)
        }
}
    
    func headerViewSxTapped() {
        self.delegate?.headerViewSxTapped()
    }
    func headerViewDxTapped() {
        self.delegate?.headerViewDxTapped()
    }
}


class HeaderView : UIView {
    class func Instance() -> HeaderView {
        return InstanceView() as! HeaderView
    }

    @IBOutlet var titleLabel: MYLabel!
    @IBOutlet var kpiLabel: MYLabel!
    @IBOutlet var sxButton: UIButton!
    @IBOutlet var dxButton: UIButton!
    
    weak var delegate:HeaderViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        kpiLabel.layer.cornerRadius = self.kpiLabel.frame.size.height / 2
        kpiLabel.layer.masksToBounds = true
    }
    
    @IBAction func sxButtonTapped() {
        self.delegate?.headerViewSxTapped()
    }
    
    @IBAction func dxButtonTapped() {
        self.delegate?.headerViewDxTapped()
    }
}

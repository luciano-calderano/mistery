//
//  MYTextField
//  Lc
//
//  Created by Luciano Calderano on 03/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

class MYTextField: UITextField {
    
    var myPlaceHolder = ""
    @IBOutlet var nextTextField: MYTextField?
    
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    override internal func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }
    
    fileprivate func initialize () {
        self.placeholder = self.placeholder?.toLang()
        self.spellCheckingType = .no
        self.autocorrectionType = .no
        self.autocapitalizationType = (self.keyboardType == .default) ? .sentences : .none
    }
    
    func showError () {
        self.becomeFirstResponder()
    }
    
    fileprivate func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}

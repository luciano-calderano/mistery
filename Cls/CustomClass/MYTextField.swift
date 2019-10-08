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
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    override internal func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    fileprivate func initialize () {
        placeholder = self.placeholder?.toLang()
        spellCheckingType = .no
        autocorrectionType = .no
        autocapitalizationType = (self.keyboardType == .default) ? .sentences : .none
        backgroundColor = .white
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

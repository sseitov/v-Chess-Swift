//
//  yAxizView.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 12.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class yAxizView: UIView {
    
    var rotated = false {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        let step = rect.size.height/8
        var textRect = CGRect(x: 0, y: rect.size.height - step, width: 20, height: step)
        let font = IS_PAD() ? UIFont.condensedFont(17) : UIFont.condensedFont(13)
        if rotated {
            for i in (1...8).reversed() {
                let text = "\(i)" as NSString
                text.draw(font, color: UIColor.white, rect: textRect)
                textRect.origin.y -= step
            }
        } else {
            for i in 1...8 {
                let text = "\(i)" as NSString
                text.draw(font, color: UIColor.white, rect: textRect)
                textRect.origin.y -= step
            }
        }
    }
    
}

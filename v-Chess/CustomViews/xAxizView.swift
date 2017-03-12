//
//  xAxizView.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 11.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class xAxizView: UIView {

    var rotated = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    let cellNames = ["A", "B", "C", "D", "E", "F", "G", "H"]
    
    override func draw(_ rect: CGRect) {
        let step = (rect.size.width - 20)/8
        var textRect = CGRect(x: 20, y: 0, width: step, height: 20)
        let font = IS_PAD() ? UIFont.condensedFont(17) : UIFont.condensedFont(13)
        if rotated {
            for i in (0...7).reversed() {
                let text = cellNames[i] as NSString
                text.draw(font, color: UIColor.white, rect: textRect)
                textRect.origin.x += step
            }
        } else {
            for i in 0...7 {
                let text = cellNames[i] as NSString
                text.draw(font, color: UIColor.white, rect: textRect)
                textRect.origin.x += step
            }
        }
    }
}

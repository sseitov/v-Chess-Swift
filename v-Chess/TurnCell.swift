//
//  TurnCell.swift
//  v-Chess
//
//  Created by Sergey Seitov on 17.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class TurnCell: UITableViewCell {

    var number:Int = 0 {
        didSet {
            numberView.text = "\(number + 1))"
        }
    }
    
    var numberView:UILabel!
    var white:UIButton!
    var black:UIButton!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        numberView = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 60))
        numberView.font = UIFont.condensedFont()
        numberView.textAlignment = .center
        numberView.backgroundColor = UIColor.groupTableViewBackground
        numberView.textColor = UIColor.mainColor()
        self.contentView.addSubview(numberView)

        white = UIButton(type: .custom)
        white.frame = CGRect(x: 30, y: 10, width: 80, height: 40)
        white.titleLabel?.font = UIFont.mainFont()
        white.backgroundColor = UIColor.white
        white.setTitleColor(UIColor.black, for: .normal)
        white.setupBorder(UIColor.white, radius: 20)
        self.contentView.addSubview(white)

        black = UIButton(type: .custom)
        black.frame = CGRect(x: 110, y: 10, width: 80, height: 40)
        black.titleLabel?.font = UIFont.mainFont()
        black.backgroundColor = UIColor.black
        black.setTitleColor(UIColor.white, for: .normal)
        black.setupBorder(UIColor.black, radius: 20)
        self.contentView.addSubview(black)
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

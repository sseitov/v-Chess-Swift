//
//  TurnCell.swift
//  v-Chess
//
//  Created by Sergey Seitov on 17.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

let unsetCurrentTurnNotification = Notification.Name("UNSET_CURRENT_TURN")

protocol TurnCellDelegate {
    func didSetCurrentTurn(_ number:Int, white:Bool)
}

class TurnCell: UITableViewCell {

    var delegate:TurnCellDelegate?
    
    func setTurn(number:Int, white:String, black:String) {
        self.number = number
        numberView.text = "\(number + 1)."
        whiteView.setTitle(white, for: .normal)
        blackView.isHidden = black.isEmpty
        blackView.setTitle(black, for: .normal)
        currentTurn = nil
    }
    
    var currentTurn:Bool? {
        didSet {
            if currentTurn != nil {
                if currentTurn! {
                    whiteView.setupBorder(UIColor.red, radius: 20, width: 4)
                    blackView.setupBorder(UIColor.black, radius: 20)
                } else {
                    whiteView.setupBorder(UIColor.white, radius: 20)
                    blackView.setupBorder(UIColor.red, radius: 20, width: 4)
                }
            } else {
                whiteView.setupBorder(UIColor.white, radius: 20)
                blackView.setupBorder(UIColor.black, radius: 20)
            }
        }
    }
    
    private var number:Int = 0
    private var numberView:UILabel!
    private var whiteView:UIButton!
    private var blackView:UIButton!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        numberView = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 60))
        numberView.font = UIFont.condensedFont(15)
        numberView.textAlignment = .center
        numberView.backgroundColor = UIColor.groupTableViewBackground
        numberView.textColor = UIColor.mainColor()
        self.contentView.addSubview(numberView)

        whiteView = UIButton(type: .custom)
        whiteView.frame = CGRect(x: 30, y: 10, width: 80, height: 40)
        whiteView.titleLabel?.font = UIFont.mainFont()
        whiteView.backgroundColor = UIColor.white
        whiteView.setTitleColor(UIColor.black, for: .normal)
        whiteView.addTarget(self, action: #selector(self.touchWhite), for: .touchUpInside)
        whiteView.setupBorder(UIColor.white, radius: 20)
        self.contentView.addSubview(whiteView)

        blackView = UIButton(type: .custom)
        blackView.frame = CGRect(x: 110, y: 10, width: 80, height: 40)
        blackView.titleLabel?.font = UIFont.mainFont()
        blackView.backgroundColor = UIColor.black
        blackView.setTitleColor(UIColor.white, for: .normal)
        blackView.addTarget(self, action: #selector(self.touchBlack), for: .touchUpInside)
        blackView.setupBorder(UIColor.black, radius: 20)
        self.contentView.addSubview(blackView)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.setCurrentTurnNotify(_:)),
                                               name: unsetCurrentTurnNotification,
                                               object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setCurrentTurnNotify(_ notify:Notification) {
        let num = notify.object as! Int
        if (number != num) {
            currentTurn = nil
        } else {
            currentTurn = notify.userInfo!["color"] as? Bool
        }
    }
    
    func touchWhite() {
        delegate?.didSetCurrentTurn(number, white: true)
//        currentTurn = true
        NotificationCenter.default.post(name: unsetCurrentTurnNotification, object: number, userInfo: ["color" : true])
    }
    
    func touchBlack() {
        delegate?.didSetCurrentTurn(number, white: false)
//        currentTurn = false
        NotificationCenter.default.post(name: unsetCurrentTurnNotification, object: number, userInfo: ["color" : false])
    }
}

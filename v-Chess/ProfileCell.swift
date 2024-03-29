//
//  ProfileCell.swift
//  v-Channel
//
//  Created by Сергей Сейтов on 09.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

protocol ProfileCellDelegate {
    func signOut()
}

class ProfileCell: UITableViewCell {
    
    @IBOutlet weak var accountType: UILabel!
    @IBOutlet weak var account: UILabel!
    @IBOutlet weak var signButton: UIButton!
    
    var delegate:ProfileCellDelegate?
    
    @IBAction func signOut(_ sender: Any) {
        delegate?.signOut()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        signButton.setupBorder(UIColor.clear, radius: 10)
    }
}

class ProfileStatusCell: UITableViewCell {
    
    @IBOutlet weak var availableSwitch: UISwitch!
    
    @IBAction func changeAvailable(_ sender: UISwitch) {
        currentUser()!.setAvailable(sender.isOn ? .available : .closed)
    }    
}

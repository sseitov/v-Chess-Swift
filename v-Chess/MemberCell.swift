//
//  MemberCell.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 13.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import SDWebImage

class MemberCell: UITableViewCell {

    var member:User? {
        didSet {
            if member!.avatar != nil, let image = UIImage(data: member!.avatar as! Data) {
                memberView.image = image.withSize(memberView.frame.size).inCircle()
            } else if member!.avatarURL != nil, let url = URL(string: member!.avatarURL!) {
                print(url)
                memberView.sd_setImage(with: url)
            }
            memberName.text = member!.name
            if member!.available {
                memberName.textColor = UIColor.mainColor()
            } else {
                memberName.textColor = UIColor.mainColor(0.4)
            }
        }
    }
    
    @IBOutlet weak var memberView: UIImageView!
    @IBOutlet weak var memberName: UILabel!

}

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

    @IBOutlet weak var memberView: UIImageView!
    @IBOutlet weak var memberName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    var member:AppUser? {
        didSet {
            if member!.avatar != nil, let data = member!.avatar as Data?, let image = UIImage(data: data) {
                memberView.image = image.withSize(memberView.frame.size).inCircle()
            } else if member!.avatarURL != nil, let url = URL(string: member!.avatarURL!) {
                memberView.sd_setImage(with: url)
            }
            if member!.name != nil && !member!.name!.isEmpty {
                memberName.text = member!.name
            } else {
                memberName.text = member!.email
            }
            memberName.textColor = MainColor
        }
    }
    
}

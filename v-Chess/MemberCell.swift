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
    @IBOutlet weak var partnerView: UIImageView!
    @IBOutlet weak var partnerName: UILabel!
    @IBOutlet weak var waiting: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var onlineGame:[String:String]? {
        didSet {
            partnerView.isHidden = false
            partnerName.isHidden = false
            waiting.isHidden = false

            if let white = Model.shared.getUser(onlineGame!["white"]!), let black = Model.shared.getUser(onlineGame!["black"]!) {
                if white.avatar != nil, let data = white.avatar as Data?, let image = UIImage(data: data) {
                    self.memberView.image = image.withSize(self.memberView.frame.size).inCircle()
                } else if white.avatarURL != nil, let url = URL(string: white.avatarURL!) {
                    SDWebImageDownloader.shared().downloadImage(with: url, options: [], progress: nil, completed: { image, _, _, _ in
                        if image != nil {
                            self.memberView.image = image!.withSize(self.memberView.frame.size).inCircle()
                        }
                    })
                }
                self.memberName.text = white.name
                
                if black.avatar != nil, let data =  black.avatar as Data?, let image = UIImage(data: data) {
                    self.partnerView.image = image.withSize(self.partnerView.frame.size).inCircle()
                } else if black.avatarURL != nil, let url = URL(string: black.avatarURL!) {
                    SDWebImageDownloader.shared().downloadImage(with: url, options: [], progress: nil, completed: { image, _, _, _ in
                        if image != nil {
                            self.memberView.image = image!.withSize(self.memberView.frame.size).inCircle()
                        }
                    })
                }
                self.partnerName.text = white.name
                
                if (white.status() == .invited && white == currentUser()) || (black.status() == .invited && black == currentUser()) {
                    self.waiting.startAnimating()
                    memberName.textColor = UIColor.mainColor(0.4)
                    partnerName.textColor = UIColor.mainColor(0.4)
                } else {
                    self.waiting.stopAnimating()
                    memberName.textColor = UIColor.mainColor()
                    partnerName.textColor = UIColor.mainColor()
                }
            }
        }
    }
    
    var member:User? {
        didSet {
            partnerView.isHidden = true
            partnerName.isHidden = true
            waiting.isHidden = true
            
            if member!.avatar != nil, let data = member!.avatar as Data?, let image = UIImage(data: data) {
                memberView.image = image.withSize(memberView.frame.size).inCircle()
            } else if member!.avatarURL != nil, let url = URL(string: member!.avatarURL!) {
                memberView.sd_setImage(with: url)
            }
            memberName.text = member!.name
            switch member!.status() {
            case .closed:
                memberName.textColor = UIColor.mainColor(0.4)
            default:
                memberName.textColor = UIColor.mainColor()
            }
        }
    }
    
}

//
//  CommunityController.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 13.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import SVProgressHUD

class CommunityController: UITableViewController {

    var online:[Any] = []
    var available:[User] = []
    var notAvailable:[User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle("Game Room")
        setupBackButton()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.refresh),
                                               name: refreshUserNotification,
                                               object: nil)
        refresh()
    }
    
    func refresh() {
        Model.shared.onlineGames({ games in
            self.online = games
            self.available = Model.shared.availableUsers(true)
            self.notAvailable = Model.shared.availableUsers(false)
            self.tableView.reloadData()
        })
    }
    
    override func goBack() {
        self.navigationController?.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return online.count
        case 1:
            return available.count
        default:
            return notAvailable.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "playing online"
        case 1:
            return "available for invitations"
        default:
            return "not available"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "member", for: indexPath) as! MemberCell
        switch indexPath.section {
        case 0:
            cell.onlineGame = online[indexPath.row] as? [String:String]
        case 1:
            cell.member = available[indexPath.row]
        default:
            cell.member = notAvailable[indexPath.row]
        }
        return cell
    }

    private func invite(_ user:User, toGame:[String:String]) {
        SVProgressHUD.show(withStatus: "Invite...")
        Model.shared.pushGame(to: user, type: .invite, game: toGame, error: { error in
            SVProgressHUD.dismiss()
            if error != nil {
                self.showMessage(error!.localizedDescription, messageType: .error)
            } else {
                self.refresh()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let user = available[indexPath.row]
            let alert = ActionSheet.create(title: "What color you choose?", actions: ["WHITE", "BLACK"], handler1: {
                let game = ["uid" : generateUDID(), "white" : currentUser()!.uid!, "black" : user.uid!]
                self.invite(user, toGame: game)
            }, handler2: {
                let game = ["uid" : generateUDID(), "white" : user.uid!, "black" : currentUser()!.uid!]
                self.invite(user, toGame: game)
            })
            alert?.firstButton.backgroundColor = UIColor.white
            alert?.firstButton.setupBorder(UIColor.black, radius: 1)
            alert?.firstButton.setTitleColor(UIColor.black, for: .normal)
            alert?.secondButton.backgroundColor = UIColor.black
            alert?.show()

        }
    }

}

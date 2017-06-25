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

    var available:[AppUser] = []
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var availableSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle("Game Room")
        setupBackButton()
        signOutButton.setupCircle()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.refresh),
                                               name: refreshUserNotification,
                                               object: nil)
        
        if currentUser() == nil {
            performSegue(withIdentifier: "login", sender: nil)
        } else {
            Model.shared.startObservers()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentUser() != nil {
            userName.text = currentUser()!.name
            userEmail.text = currentUser()!.email
            if let data = currentUser()!.avatar as Data?, let image = UIImage(data: data) {
                userImage.image = image.withSize(userImage.frame.size).inCircle()
            }
            availableSwitch.isOn = currentUser()!.isAvailable()
            refresh()
        }
    }
    
    func refresh() {
        if currentUser()!.isAvailable() {
            let btn = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshUsers))
            btn.tintColor = UIColor.white
            navigationItem.setRightBarButton(btn, animated: true)
            self.available = Model.shared.availableUsers()
        } else {
            navigationItem.setRightBarButton(nil, animated: true)
            self.available = []
        }
        self.tableView.reloadData()
    }
    
    func refreshUsers() {
        SVProgressHUD.show(withStatus: "Refresh...")
        Model.shared.refreshUsers({ users in
            SVProgressHUD.dismiss()
        })
    }
    
    override func goBack() {
        self.navigationController?.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }

    @IBAction func signOut(_ sender: Any) {
        yesNoQuestion("Are you shure you want sign out?", acceptLabel: "SignOut", cancelLabel: "Cancel", acceptHandler: {
            SVProgressHUD.show(withStatus: "SignOut...")
            Model.shared.signOut {
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "login", sender: nil)
            }
        })
    }
    
    @IBAction func switchAvailable(_ sender: UISwitch) {
        if sender.isOn {
            currentUser()?.setAvailable(.available)
        } else {
            currentUser()?.setAvailable(.closed)
        }
        refresh()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return available.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Members available for invitation"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "member", for: indexPath) as! MemberCell
        cell.member = available[indexPath.row]
        return cell
    }

    private func invite(_ user:AppUser, toGame:[String:String]) {
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

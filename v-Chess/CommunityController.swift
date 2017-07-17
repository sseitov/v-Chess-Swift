//
//  CommunityController.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 13.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import GoogleSignIn

class CommunityController: UITableViewController, GIDSignInDelegate {

    var available:[AppUser] = []
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var availableSwitch: UISwitch!
    
    private var inviteEnabled = false
    
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
            if let provider = Auth.auth().currentUser!.providerData.first {
                if provider.providerID == "google.com" {
                    GIDSignIn.sharedInstance().clientID = "1032784464543-hpfitve3jg6v4778449efiv6niddr098.apps.googleusercontent.com"
                    GIDSignIn.sharedInstance().delegate = self
                    GIDSignIn.sharedInstance().signInSilently()
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if user != nil {
            inviteEnabled = true
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .fade)
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
                self.tableView.reloadData()
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
        if currentUser() != nil {
            if currentUser()!.isAvailable() {
                return 2
            } else {
                return 1
            }
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 1 : 40
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentUser() != nil {
            if section == 0 {
                return inviteEnabled ? 1 : 0
            } else {
                return available.count
            }
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "members that available for offer" : ""
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.mainFont(15)
            cell.textLabel?.textColor = MainColor
            cell.textLabel?.text = "Invite your friends into v-Chess Game Room"
            cell.imageView?.image = UIImage(named: "invite")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "member", for: indexPath) as! MemberCell
            cell.member = available[indexPath.row]
            return cell
        }
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
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: false)
            sendInvite()
        } else {
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

    func sendInvite() {
        if let invite = Invites.inviteDialog() {
            invite.setInviteDelegate(self)
            let message = "\(currentUser()!.name!) invite you into v-Chess Game Room!"
            invite.setMessage(message)
            invite.setTitle("Invite")
            invite.setDeepLink(deepLink)
            invite.setCallToActionText("Install")
            invite.open()
        }
    }
}

extension CommunityController : InviteDelegate {
    
    func inviteFinished(withInvitations invitationIds: [String], error: Error?) {
        if let error = error {
            if error.localizedDescription != "Canceled by User" {
                let message = "Can not send invite. Error: \(error.localizedDescription)"
                showMessage(message, messageType: .error)
            }
        } else {
            let message = "\(invitationIds.count) invites sent."
            showMessage(message, messageType: .information)
        }
    }
}

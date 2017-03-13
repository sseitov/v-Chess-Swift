//
//  SettingsController.swift
//  v-Channel
//
//  Created by Сергей Сейтов on 22.02.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import SVProgressHUD

class SettingsController: UITableViewController, ProfileCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle("My Profile")
        setupBackButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    override func goBack() {
        self.navigationController?.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "account" : "settings"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let profileCell = tableView.dequeueReusableCell(withIdentifier: "available", for: indexPath) as! ProfileStatusCell
            profileCell.availableSwitch.isOn = currentUser()!.isAvailable()
            return profileCell
        } else {
            let profileCell = tableView.dequeueReusableCell(withIdentifier: "profile", for: indexPath) as! ProfileCell
            profileCell.accountType.text = currentUser()!.socialTypeName()
            profileCell.account.text = currentUser()!.email!
            profileCell.delegate = self
            return profileCell
        }
    }
    
    func signOut() {
        let alert = createQuestion("Are you really want to sign out?", acceptTitle: "Sure", cancelTitle: "Cancel", acceptHandler: {
            SVProgressHUD.show(withStatus: "SignOut...")
            Model.shared.signOut({
                SVProgressHUD.dismiss()
                self.goBack()
            })
        })
        alert?.show()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: "selectRingtone", sender: nil)
        }
    }

}

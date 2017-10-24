//
//  MenuController.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 13.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import AMSlideMenu

class MenuController: AMSlideMenuRightTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.gameNotify(_:)),
                                               name: gameNotification,
                                               object: nil)
    }
    
    @objc func gameNotify(_ notify:Notification) {
        let type = notify.object as! GamePush
        if type == .invite {
            Model.shared.myGame({ game, error in
                if error == nil {
                    let aps = notify.userInfo!["aps"] as! [AnyHashable : Any]
                    let alert = aps["alert"] as! [AnyHashable : Any]
                    let text = alert["body"] as! String
                    let userID = currentUser()!.uid! == game!["white"] ? game!["black"] : game!["white"]
                    if let user = Model.shared.getUser(userID!) {
                        self.yesNoQuestion(text, acceptLabel: "Accept", cancelLabel: "Reject", acceptHandler: {
                            Model.shared.pushGame(to: user, type: .accept, game: game!, error: { err in
                                if err == nil {
                                    self.performSegue(withIdentifier: "play", sender: game)
                                } else {
                                    self.showMessage(err!.localizedDescription, messageType: .error)
                                }
                            })
                        }, cancelHandler: {
                            Model.shared.pushGame(to: user, type: .reject, game: game!, error: { err in
                            })
                        })
                    }
                }
            })
        } else if type == .accept {
            Model.shared.myGame({ game, error in
                if error == nil {
                    let aps = notify.userInfo!["aps"] as! [AnyHashable : Any]
                    let alert = aps["alert"] as! [AnyHashable : Any]
                    let text = alert["body"] as! String
                    self.showMessage(text, messageType: .information, messageHandler: {
                        self.performSegue(withIdentifier: "play", sender: game)
                    })
                }
            })
        } else if type == .reject {
            let aps = notify.userInfo!["aps"] as! [AnyHashable : Any]
            let alert = aps["alert"] as! [AnyHashable : Any]
            let text = alert["body"] as! String
            self.showMessage(text, messageType: .error)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return navBarHeight()
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: navBarHeight()))
        label.textAlignment = .center
        label.font = UIFont.condensedFont(13)
        label.text = "v-Chess menu".uppercased()
        label.textColor = UIColor.white
        label.backgroundColor = MainColor
        return label
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.imageView?.setupBorder(UIColor.white, radius: 40, width: 3)
        switch indexPath.row {
        case 1:
            cell.textLabel?.text = "Games Archive".uppercased()
            cell.imageView?.image = UIImage(named: "archive")!.withSize(CGSize(width: 80, height: 80)).inCircle()
        case 2:
            cell.textLabel?.text = "game room".uppercased()
            cell.imageView?.image = UIImage(named: "community")!.withSize(CGSize(width: 80, height: 80)).inCircle()
        default:
            cell.textLabel?.text = "Play".uppercased()
            cell.imageView?.image = UIImage(named: "logo")!.withSize(CGSize(width: 80, height: 80)).inCircle()
        }
        cell.contentView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.font = UIFont.condensedFont()
        cell.textLabel?.textColor = MainColor
        cell.textLabel?.textAlignment = .center
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        UserDefaults.standard.set(indexPath.row, forKey: "lastMenuChoice")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToMenu(_ segue: UIStoryboardSegue) {
        let nav = segue.source as! UINavigationController
        if let archive = nav.topViewController as? MasterLoader {
            performSegue(withIdentifier: "play", sender: archive.mSelectedGame)
        } else {
            mainVC.openRightMenu(animated: true)
        }
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "play" {
            let nav = segue.destination as! UINavigationController
            let next = nav.topViewController as! BoardController
            if let chessGame = sender as? ChessGame {
                next.chessGame = chessGame
            } else {
                next.onlineGame = sender as? [String:String]
            }
        }
    }

}

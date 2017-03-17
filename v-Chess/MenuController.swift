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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
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
        label.backgroundColor = UIColor.mainColor()
        return label
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.imageView?.setupBorder(UIColor.white, radius: 40, width: 3)
        switch indexPath.row {
        case 1:
            cell.textLabel?.text = "game room".uppercased()
            cell.imageView?.image = UIImage(named: "community")!.withSize(CGSize(width: 80, height: 80)).inCircle()
        case 2:
            cell.textLabel?.text = "Games Archive".uppercased()
            cell.imageView?.image = UIImage(named: "archive")!.withSize(CGSize(width: 80, height: 80)).inCircle()
        case 3:
            cell.textLabel?.text = "settings".uppercased()
            cell.imageView?.image = UIImage(named: "settings")!.withSize(CGSize(width: 80, height: 80)).inCircle()
        default:
            cell.textLabel?.text = "Play".uppercased()
            cell.imageView?.image = UIImage(named: "logo")!.withSize(CGSize(width: 80, height: 80)).inCircle()
        }
        cell.contentView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.font = UIFont.condensedFont()
        cell.textLabel?.textColor = UIColor.mainColor()
        cell.textLabel?.textAlignment = .center
        
        return cell
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToMenu(_ segue: UIStoryboardSegue) {
        if currentUser() == nil {
            performSegue(withIdentifier: "login", sender: self)
        } else {
            let nav = segue.source as! UINavigationController
            if let archive = nav.topViewController as? MasterLoader {
                performSegue(withIdentifier: "play", sender: archive.mSelectedGame)
            } else {
                mainVC.openRightMenu(animated: true)
            }
        }
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "play" {
            let nav = segue.destination as! UINavigationController
            let next = nav.topViewController as! BoardController
            next.chessGame = sender as? ChessGame
        }
    }

}

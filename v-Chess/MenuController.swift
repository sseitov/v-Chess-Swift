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
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 3 : 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? navBarHeight() : 1
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 40 : 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: navBarHeight()))
            label.textAlignment = .center
            label.font = UIFont.condensedFont(13)
            label.text = "v-Chess menu".uppercased()
            label.textColor = UIColor.white
            label.backgroundColor = UIColor.mainColor()
            return label
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.imageView?.setupBorder(UIColor.mainColor(), radius: 40, width: 3)
        if indexPath.section == 0 {
            switch indexPath.row {
            case 1:
                cell.textLabel?.text = "v-Chess Club".uppercased()
                cell.imageView?.image = UIImage(named: "community")!.withSize(CGSize(width: 80, height: 80)).inCircle()
            case 2:
                cell.textLabel?.text = "Games Archive".uppercased()
                cell.imageView?.image = UIImage(named: "archive")!.withSize(CGSize(width: 80, height: 80)).inCircle()
            default:
                cell.textLabel?.text = "Play".uppercased()
                cell.imageView?.image = UIImage(named: "logo")!.withSize(CGSize(width: 80, height: 80)).inCircle()
            }
        } else {
            cell.textLabel?.text = "settings".uppercased()
            cell.imageView?.image = UIImage(named: "settings")!.withSize(CGSize(width: 80, height: 80)).inCircle()
        }
        cell.contentView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.font = UIFont.condensedFont()
        cell.textLabel?.textColor = UIColor.mainColor()
        cell.textLabel?.textAlignment = .center
        cell.selectionStyle = .none
        
        return cell
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToMenu(_ segue: UIStoryboardSegue) {
        mainVC.openRightMenu(animated: true)
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
/*
        if segue.identifier == "play" {
            let nav = segue.destination as! UINavigationController
            let next = nav.topViewController as! BoardController
        }
 */
    }

}

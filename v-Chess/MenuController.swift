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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return navBarHeight()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: navBarHeight()))
        label.textAlignment = .center
        label.font = UIFont.condensedFont(15)
        label.text = "v-Chess menu"
        label.textColor = UIColor.mainColor()
        return label
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.imageView?.setupBorder(UIColor.mainColor(), radius: 40, width: 2)
        switch indexPath.row {
        case 1:
            cell.textLabel?.text = "v-Chess Club"
            cell.imageView?.image = UIImage(named: "community")!.withSize(CGSize(width: 80, height: 80)).inCircle()
        case 2:
            cell.textLabel?.text = "Games Archive"
            cell.imageView?.image = UIImage(named: "archive")!.withSize(CGSize(width: 80, height: 80)).inCircle()
        default:
            cell.textLabel?.text = "Play with v-Chess"
            cell.imageView?.image = UIImage(named: "logo")!.withSize(CGSize(width: 80, height: 80)).inCircle()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
/*
        if segue.identifier == "play" {
            let nav = segue.destination as! UINavigationController
            let next = nav.topViewController as! BoardController
        }
 */
    }

}

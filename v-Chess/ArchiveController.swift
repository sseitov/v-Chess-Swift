//
//  ArchiveController.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 14.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class ArchiveController: UITableViewController, ChessComLoaderDelegate {

    var users:[String] = []
    var masters:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle("Archive")
        setupBackButton()
        
        users = NSArray(array: StorageManager.shared().getUserPackages()) as! [String]
        masters = NSArray(contentsOf: Bundle.main.url(forResource: "packages", withExtension: "plist")!) as! [String]
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(self.loadGame))
        rightButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = rightButton
    }
    
    override func goBack() {
        self.navigationController?.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }

    func loadGame() {
        performSegue(withIdentifier: "importGame", sender: nil)
    }
    
    func loaderDidFinish(_ count: Int32) {
        dismiss(animated: true, completion: {
            self.users = NSArray(array: StorageManager.shared().getUserPackages()) as! [String]
            self.tableView.reloadData()
            self.showMessage("Was imported \(count) games.", messageType: .information)
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? users.count : masters.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Downloaded Games" : "Master's Games"
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.font = UIFont.condensedFont()
        cell.textLabel?.textColor = MainColor
        cell.accessoryType = .disclosureIndicator
        if indexPath.section == 0 {
            cell.textLabel?.text = users[indexPath.row]
        } else {
            cell.textLabel?.text = masters[indexPath.row]
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "openMaster", sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.section == 0)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            let package = users[indexPath.row]
            users.remove(at: indexPath.row)
            StorageManager.shared().removePackage(package)
            tableView.deleteRows(at: [indexPath], with: .top)
            tableView.endUpdates()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openMaster" {
            let next = segue.destination as! MasterLoader
            let indexPath = sender as! IndexPath
            let package = indexPath.section == 0 ? users[indexPath.row] : masters[indexPath.row]
            next.mPackageName = package
            next.mMasterEco = StorageManager.shared().eco(inPackage: package)
        } else if segue.identifier == "importGame" {
            let nav = segue.destination as! UINavigationController
            let next = nav.topViewController as! ChessComLoader
            next.delegate = self
        }
    }
}

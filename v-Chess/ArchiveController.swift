//
//  ArchiveController.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 14.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class ArchiveController: UITableViewController {

    var masters:[String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle("Archive")
        setupBackButton()
        
        masters = NSArray(contentsOf: Bundle.main.url(forResource: "packages", withExtension: "plist")!) as? [String]
    }
    
    override func goBack() {
        self.navigationController?.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? StorageManager.shared().userPackages.count : masters!.count
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
        cell.textLabel?.textColor = UIColor.mainColor()
        cell.accessoryType = .disclosureIndicator
        if indexPath.section == 0 {
            cell.textLabel?.text = StorageManager.shared().userPackages.object(at: indexPath.row) as? String
        } else {
            cell.textLabel?.text = masters![indexPath.row]
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "openMaster", sender: indexPath)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openMaster" {
            let next = segue.destination as! MasterLoader
            let indexPath = sender as! IndexPath
            if let package = indexPath.section == 0 ? StorageManager.shared().userPackages.object(at: indexPath.row) as? String : masters![indexPath.row] {
                next.mPackageName = package
                next.mMasterEco = StorageManager.shared().eco(inPackage: package)
            }
        }
    }

}

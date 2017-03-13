//
//  MainController.swift
//  WD Content
//
//  Created by Сергей Сейтов on 24.02.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import AMSlideMenu

class MainController: AMSlideMenuMainViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.isInitialStart = false
    }

    override func primaryMenu() -> AMPrimaryMenu {
        return AMPrimaryMenuRight
    }
    
    // MARK: - Right menu
    
    override func initialIndexPathForRightMenu() -> IndexPath! {
        return IndexPath(row: 0, section: 0)
    }
    
    override func segueIdentifierForIndexPath(inRightMenu indexPath: IndexPath!) -> String! {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 1:
                return "community"
            default:
                return "play"
            }
        } else {
            return "settings"
        }
    }

    override func rightMenuWidth() -> CGFloat {
        return IS_PAD() ? 320 : 260
    }
    
    override func deepnessForRightMenu() -> Bool {
        return true
    }
    
    override func maxDarknessWhileRightMenu() -> CGFloat {
        return 0.5
    }
    
    // MARK: - Common
    
    override func configureSlideLayer(_ layer: CALayer!) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 5
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(rect: self.view.layer.bounds).cgPath
    }

    override func openAnimationCurve() -> UIViewAnimationOptions {
        return .curveEaseOut
    }
    
    override func closeAnimationCurve() -> UIViewAnimationOptions {
        return .curveEaseOut
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

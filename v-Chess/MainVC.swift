//
//  MainVC.swift
//  WD Content
//
//  Created by Сергей Сейтов on 24.02.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import AMSlideMenu

class MainVC: AMSlideMenuMainViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.isInitialStart = false
    }

    override func primaryMenu() -> AMPrimaryMenu {
        return AMPrimaryMenuRight
    }
    
    override func initialIndexPathForRightMenu() -> IndexPath! {
        return IndexPath(row: 0, section: 0)
    }
    
    override func segueIdentifierForIndexPath(inRightMenu indexPath: IndexPath!) -> String! {
        return "board"
    }
    
    override func rightMenuWidth() -> CGFloat {
        return IS_PAD() ? 320 : 260
    }

    override func configureRightMenuButton(_ button: UIButton!) {
        button.frame = CGRect(x: 0, y: 0, width: 25, height: 13)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named:"menuButton"), for: .normal)
    }

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

    override func deepnessForLeftMenu() -> Bool {
        return false
    }

    override func deepnessForRightMenu() -> Bool {
        return true
    }
    
    override func maxDarknessWhileLeftMenu() -> CGFloat {
        return 0.5
    }
    
    override func maxDarknessWhileRightMenu() -> CGFloat {
        return 0.5
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

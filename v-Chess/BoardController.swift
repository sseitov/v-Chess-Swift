//
//  BoardController.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 12.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

extension UINavigationController {
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .all
    }
}

class BoardController: UIViewController {

    @IBOutlet weak var xAxiz: xAxizView!
    @IBOutlet weak var yAxiz: yAxizView!
    @IBOutlet weak var desk: Desk!
    @IBOutlet weak var boardWidth: NSLayoutConstraint!
    @IBOutlet weak var boardHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle("v-Chess")
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "velvet.png")!)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let orientation = UIApplication.shared.statusBarOrientation
        if UIInterfaceOrientationIsLandscape(orientation) {
            self.boardWidth.constant = self.view.frame.height
            self.boardHeight.constant = self.view.frame.height
        } else {
            self.boardWidth.constant = self.view.frame.width
            self.boardHeight.constant = self.view.frame.width
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
            let orientation = UIApplication.shared.statusBarOrientation
            self.setRotated((orientation == .landscapeLeft) || (orientation == .portraitUpsideDown))
            if UIInterfaceOrientationIsLandscape(orientation) {
                self.boardWidth.constant = self.view.frame.height
                self.boardHeight.constant = self.view.frame.height
            } else {
                self.boardWidth.constant = self.view.frame.width
                self.boardHeight.constant = self.view.frame.width
            }
        }) { (context: UIViewControllerTransitionCoordinatorContext) in
        }
    }
    
    func setRotated(_ rotated:Bool) {
        self.xAxiz.rotated = rotated
        self.yAxiz.rotated = rotated
        self.desk.rotated = rotated
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

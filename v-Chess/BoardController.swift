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
    @IBOutlet weak var desk: UIView!
    @IBOutlet weak var boardWidth: NSLayoutConstraint!
    @IBOutlet weak var boardHeight: NSLayoutConstraint!
    
    var chessEngine:ChessEngine?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle("Choose mode from menu")
        setupBackButton()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "velvet.png")!)
        
        let timerView = UISegmentedControl(items: ["00:00", "00:00"])
        self.navigationItem.titleView = timerView
        chessEngine = ChessEngine(view: desk, for: Depth.Fast, timerView:timerView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.youWin),
                                               name: Notification.Name("YouWinNotification"),
                                               object: nil)
    }
        
    override func goBack() {
        self.navigationController?.performSegue(withIdentifier: "unwindToMenu", sender: self)
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
        var orientation:UIInterfaceOrientation!
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
            orientation = UIApplication.shared.statusBarOrientation
            print("================= orientation \(orientation)")
            if UIInterfaceOrientationIsLandscape(orientation) {
                self.boardWidth.constant = self.view.frame.height
                self.boardHeight.constant = self.view.frame.height
            } else {
                self.boardWidth.constant = self.view.frame.width
                self.boardHeight.constant = self.view.frame.width
            }
        }) { (context: UIViewControllerTransitionCoordinatorContext) in
            self.setRotated((orientation == .landscapeLeft) || (orientation == .portraitUpsideDown))
        }
    }
    
    func setRotated(_ rotated:Bool) {
        self.xAxiz.rotated = rotated
        self.yAxiz.rotated = rotated
        chessEngine?.rotateDesk(rotated)
    }

    func youWin() {
        showMessage("Congratilations, you are win!", messageType: .information)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}

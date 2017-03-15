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
    var chessGame:ChessGame?
    
    private var observerContext = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle("Choose mode from menu")
        setupBackButton()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "velvet.png")!)
        
        if chessGame == nil {
            let timerView = UISegmentedControl(items: ["00:00", "00:00"])
            timerView.tintColor = UIColor.white
            self.navigationItem.titleView = timerView
            chessEngine = ChessEngine(view: desk, for: Depth.Fast, timerView:timerView)
            
            let controlButton = UIButton(frame: CGRect(x: 0, y: 30, width: 80, height: 30))
            controlButton.titleLabel?.font = UIFont.condensedFont()
            controlButton.setTitle("Start", for: .normal)
            controlButton.setTitleColor(UIColor.mainColor(), for: .normal)
            controlButton.backgroundColor = UIColor.white
            controlButton.setupBorder(UIColor.clear, radius: 10)
            controlButton.addTarget(self, action: #selector(self.controlGame(_:)), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: controlButton)
        } else {
            let controlView = UISegmentedControl(items: [
                UIImage(named: "rewind")!,
                UIImage(named: "previouse")!,
                UIImage(named: "stop")!,
                UIImage(named: "next")!,
                UIImage(named: "play")!
                ])
            controlView.tintColor = UIColor.white
            controlView.selectedSegmentIndex = 2
            self.navigationItem.titleView = controlView
            self.navigationItem.prompt = "\(chessGame!.white!) - \(chessGame!.black!)"
            
            chessEngine = ChessEngine(view: desk, for: chessGame, controlView: controlView)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.youWin),
                                               name: Notification.Name("YouWinNotification"),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged(_:)),
                                               name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func orientationChanged(_ notify:Notification) {
        if chessGame != nil && !IS_PAD() {
            let orientation = UIDevice.current.orientation
            if UIDeviceOrientationIsPortrait(orientation) {
                if orientation == .faceUp {
                    self.navigationItem.prompt = nil
                } else {
                    self.navigationItem.prompt = "\(chessGame!.white!) - \(chessGame!.black!)"
                }
            } else {
                self.navigationItem.prompt = nil
            }
        }
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

    private func startGame(_ button:UIButton, blackColor:Bool) {
        self.chessEngine?.startGame(blackColor)
        button.setTitle("Surrender", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.errorColor()
    }
    
    private func stopGame(_ button:UIButton) {
        self.chessEngine?.stopGame()
        button.setTitle("Start", for: .normal)
        button.setTitleColor(UIColor.mainColor(), for: .normal)
        button.backgroundColor = UIColor.white
    }
    
    func controlGame(_ button:UIButton) {
        if !chessEngine!.gameStarted() {
            let alert = ActionSheet.create(title: "What color you choose?", actions: ["WHITE", "BLACK"], handler1: {
                self.startGame(button, blackColor: true)
            }, handler2: {
                self.startGame(button, blackColor: false)
            })
            alert?.firstButton.backgroundColor = UIColor.white
            alert?.firstButton.setupBorder(UIColor.black, radius: 1)
            alert?.firstButton.setTitleColor(UIColor.black, for: .normal)
            alert?.secondButton.backgroundColor = UIColor.black
            alert?.show()
        } else {
            let alert = createQuestion("You are really surrender?", acceptTitle: "Yes", cancelTitle: "Cancel", acceptHandler: {
                self.stopGame(button)
            })
            alert?.show()
        }
    }
    
    func youWin() {
        showMessage("Congratilations, you are win!", messageType: .information)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}

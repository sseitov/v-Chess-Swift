//
//  BoardController.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 12.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import SVProgressHUD

extension UINavigationController {
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .all
    }
}

enum ViewerCommand:Int {
    case rewind = 0
    case previouse = 1
    case next = 2
}

class BoardController: UIViewController, TurnCellDelegate {

    @IBOutlet weak var xAxiz: xAxizView!
    @IBOutlet weak var yAxiz: yAxizView!
    @IBOutlet weak var desk: UIView!
    @IBOutlet weak var boardWidth: NSLayoutConstraint!
    @IBOutlet weak var boardHeight: NSLayoutConstraint!
    @IBOutlet weak var whiteEatView: UIView!
    @IBOutlet weak var blackEatView: UIView!
    
    var whiteEat: EatController?
    var blackEat: EatController?
    
    var chessEngine:ChessEngine?
    var chessGame:ChessGame?
    
    var onlineGame:[String:String]?
    var partner:User?
    
    var notationTable:UITableView?
    var status:UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitle("Choose mode from menu")
        setupBackButton()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "velvet.png")!)

        mainController?.disableSlider()
        
        if chessGame == nil && onlineGame == nil {
            let timerView = UISegmentedControl(items: ["00:00", "00:00"])
            timerView.tintColor = UIColor.white
            self.navigationItem.titleView = timerView
            
            chessEngine = ChessEngine(view: desk, timerView:timerView)
            chessEngine?.whiteEat = whiteEat
            chessEngine?.blackEat = blackEat
            
            let controlButton = UIButton(frame: CGRect(x: 0, y: 30, width: 80, height: 30))
            controlButton.titleLabel?.font = UIFont.condensedFont()
            controlButton.setTitle("Start", for: .normal)
            controlButton.setTitleColor(UIColor.mainColor(), for: .normal)
            controlButton.backgroundColor = UIColor.white
            controlButton.setupBorder(UIColor.clear, radius: 15)
            controlButton.addTarget(self, action: #selector(self.controlGame(_:)), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: controlButton)

            let soundTitle = UIBarButtonItem(title: "Sound", style: .plain, target: nil, action: nil)
            soundTitle.tintColor = UIColor.white
            let soundControl = UISwitch()
            soundControl.isOn = isSoundEnabled()
            soundControl.addTarget(self, action: #selector(self.controlSound(_:)), for: .valueChanged)
            let soundSwitch = UIBarButtonItem(customView: soundControl)
            
            let stretch = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            let depthTitle = UIBarButtonItem(title: "Strong depth", style: .plain, target: nil, action: nil)
            depthTitle.tintColor = UIColor.white
            let depthControl = UISwitch()
            depthControl.isOn = (chessDepth() == .Strong)
            depthControl.addTarget(self, action: #selector(self.controlDepth(_:)), for: .valueChanged)
            let depthSwitch = UIBarButtonItem(customView: depthControl)
            toolbarItems = [soundTitle, soundSwitch, stretch, depthTitle, depthSwitch]
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.youWin),
                                                   name: Notification.Name("YouWinNotification"),
                                                   object: nil)
        } else if chessGame != nil {
            let controlView = UISegmentedControl(items: [
                UIImage(named: "rewind")!,
                UIImage(named: "previouse")!,
                UIImage(named: "next")!,
                ])
            for i in 0...2 {
                controlView.setWidth(100, forSegmentAt: i)
            }
            controlView.tintColor = UIColor.white
            controlView.isMomentary = true
            controlView.addTarget(self, action: #selector(self.controlViewer(_:)), for: .valueChanged)
            let stretch = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            self.toolbarItems = [stretch, UIBarButtonItem(customView: controlView), stretch]
            setupTitle("\(chessGame!.white!) - \(chessGame!.black!)")
            
            chessEngine = ChessEngine(view: desk)
            chessEngine?.whiteEat = whiteEat
            chessEngine?.blackEat = blackEat
            
            SVProgressHUD.show(withStatus: "Load...")
            DispatchQueue.global().async {
                let success = self.chessEngine?.setupGame(self.chessGame)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    if success == nil || !success! {
                        controlView.isEnabled = false
                        self.showMessage("Error parsing game.", messageType: .error)
                    } else {
                        self.notationTable = UITableView(frame: CGRect(x: self.view.frame.size.width, y: 0, width: 200, height: self.view.frame.size.height), style: .grouped)
                        self.notationTable?.autoresizingMask = UIViewAutoresizing.flexibleHeight.union(.flexibleLeftMargin)
                        self.notationTable?.delegate = self
                        self.notationTable?.dataSource = self
                        self.notationTable?.isHidden = true
                        self.notationTable?.setupBorder(UIColor.mainColor(), radius: 1, width: 2)
                        self.view.addSubview(self.notationTable!)
                        
                        let btn = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.showTable))
                        btn.tintColor = UIColor.white
                        self.navigationItem.rightBarButtonItem = btn
                        
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
                        self.view.addGestureRecognizer(tap)
                    }
                }
            }
        } else {
            partner = Model.shared.gamePartner(onlineGame!)
            
            let timerView = UISegmentedControl(items: ["00:00", "00:00"])
            timerView.tintColor = UIColor.white
            self.navigationItem.titleView = timerView
            
            chessEngine = ChessEngine(view: desk, timerView:timerView)
            chessEngine?.whiteEat = whiteEat
            chessEngine?.blackEat = blackEat
            
            let white = onlineGame!["white"]! == currentUser()!.uid
            chessEngine?.startOnlineGame(white)
            
            let controlButton = UIButton(frame: CGRect(x: 0, y: 30, width: 80, height: 30))
            controlButton.titleLabel?.font = UIFont.condensedFont()
            controlButton.setTitle("Surrender", for: .normal)
            controlButton.setTitleColor(UIColor.white, for: .normal)
            controlButton.backgroundColor = UIColor.errorColor()
            controlButton.setupBorder(UIColor.clear, radius: 15)
            controlButton.addTarget(self, action: #selector(self.controlGame(_:)), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: controlButton)
            
            if !white {
                status = UIBarButtonItem(title: "Waiting move from \(partner!.name!)", style: .plain, target: nil, action: nil)
            } else {
                status = UIBarButtonItem(title: "You need make move", style: .plain, target: nil, action: nil)
            }
            status?.tintColor = UIColor.white
            let stretch = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            self.toolbarItems = [stretch, status!, stretch]
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.gameNotify(_:)),
                                                   name: gameNotification,
                                                   object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.sendTurn(_:)),
                                                   name: Notification.Name("MyTurnNotification"),
                                                   object: nil)
        }
    }
    
    override func goBack() {
        self.navigationController?.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    func tap() {
        if !notationTable!.isHidden {
            showTable()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let orientation = UIApplication.shared.statusBarOrientation
        if UIInterfaceOrientationIsLandscape(orientation) {
            self.boardWidth.constant = self.view.frame.height
            self.boardHeight.constant = self.view.frame.height
            whiteEatView.frame = whiteEatFrame(landscape: true)
            blackEatView.frame = blackEatFrame(landscape: true)
        } else {
            self.boardWidth.constant = self.view.frame.width
            self.boardHeight.constant = self.view.frame.width
            whiteEatView.frame = whiteEatFrame(landscape: false)
            blackEatView.frame = blackEatFrame(landscape: false)
        }
    }
    
    private func isRotated(_ orientation:UIInterfaceOrientation) -> Bool {
        return (orientation == .landscapeLeft) || (orientation == .portraitUpsideDown)
    }
    
    private func whiteEatFrame(landscape:Bool) -> CGRect {
        if landscape {
            return CGRect(x: self.view.frame.size.width - (self.view.frame.size.width - self.view.frame.size.height)/2 + 10,
                          y: 10,
                          width: (self.view.frame.size.width - self.view.frame.size.height)/2 - 20,
                          height: self.view.frame.size.height - 20)
        } else {
            return CGRect(x: 10,
                          y: self.view.frame.size.height - (self.view.frame.size.height - self.view.frame.size.width)/2 + 10,
                          width: self.view.frame.size.width - 10,
                          height: (self.view.frame.size.height - self.view.frame.size.width)/2 - 20)
        }
    }
    
    private func blackEatFrame(landscape:Bool) -> CGRect {
        if landscape {
            return CGRect(x: 10,
                          y: 10,
                          width: (self.view.frame.size.width - self.view.frame.size.height) / 2 - 20,
                          height: self.view.frame.size.height - 20)
        } else {
            return CGRect(x: 10,
                          y: 10,
                          width: self.view.frame.size.width - 10,
                          height: (self.view.frame.size.height - self.view.frame.size.width) / 2 - 20)
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
                if self.isRotated(orientation) {
                    self.blackEatView.frame = self.whiteEatFrame(landscape: true)
                    self.whiteEatView.frame = self.blackEatFrame(landscape: true)
                } else {
                    self.blackEatView.frame = self.blackEatFrame(landscape: true)
                    self.whiteEatView.frame = self.whiteEatFrame(landscape: true)
                }
            } else {
                self.boardWidth.constant = self.view.frame.width
                self.boardHeight.constant = self.view.frame.width
                if self.isRotated(orientation) {
                    self.blackEatView.frame = self.whiteEatFrame(landscape: false)
                    self.whiteEatView.frame = self.blackEatFrame(landscape: false)
                } else {
                    self.blackEatView.frame = self.blackEatFrame(landscape: false)
                    self.whiteEatView.frame = self.whiteEatFrame(landscape: false)
                }
            }
        }) { (context: UIViewControllerTransitionCoordinatorContext) in
            self.setRotated(self.isRotated(orientation))
        }
    }
    
    func setRotated(_ rotated:Bool) {
        self.xAxiz.rotated = rotated
        self.yAxiz.rotated = rotated
        chessEngine?.rotateDesk(rotated)
    }

    private func startGame(_ button:UIButton, blackColor:Bool) {
        self.chessEngine?.startGame(blackColor, for: chessDepth())
        button.setTitle("Surrender", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.errorColor()
    }
    
    private func stopGame(_ button:UIButton) {
        self.chessEngine?.stopGame()
        if onlineGame != nil {
            SVProgressHUD.show(withStatus: "Surrender...")
            Model.shared.pushGame(to: partner!, type: .surrender, game: onlineGame!, error: { error in
                SVProgressHUD.dismiss()
                if error != nil {
                    self.showMessage(error!.localizedDescription, messageType: .error, messageHandler: {
                        self.goBack()
                    })
                } else {
                    self.goBack()
                }
            })
        } else {
            button.setTitle("Start", for: .normal)
            button.setTitleColor(UIColor.mainColor(), for: .normal)
            button.backgroundColor = UIColor.white
        }
    }
    
    func controlDepth(_ sender:UISwitch) {
        setChessDepth(sender.isOn)
        chessEngine?.depth = chessDepth()
    }
    
    func controlSound(_ sender:UISwitch) {
        chessEngine?.soundEnable = sender.isOn
        setSoundEnabled(sender.isOn)
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
    
    func playBack(_ control:UISegmentedControl) {
        if !self.notationTable!.isHidden {
            showTable()
        }
        chessEngine?.turnBack({ next in
            if (next) {
                self.playBack(control)
            } else {
                control.isUserInteractionEnabled = true
                let indexPath = IndexPath(row: 0, section: 0)
                self.notationTable?.reloadData()
                self.notationTable?.selectRow(at: indexPath, animated: false, scrollPosition: .top)
                return;
            }
        })
    }
    
    func controlViewer(_ control:UISegmentedControl) {
        let command = ViewerCommand(rawValue: control.selectedSegmentIndex)
        switch command! {
        case .rewind:
            control.isUserInteractionEnabled = false
            playBack(control)
            break
        case .previouse:
            control.isUserInteractionEnabled = false
            chessEngine?.turnBack({ next in
                control.isUserInteractionEnabled = true
                let row = self.chessEngine!.currentIndex() > 0 ? (self.chessEngine!.currentIndex() - 1)/2 : 0
                let indexPath = IndexPath(row: row, section: 0)
                if let visible = self.notationTable?.indexPathsForVisibleRows {
                    if visible.index(of: indexPath) == nil {
                        self.notationTable?.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                    }
                }
                var paths:[IndexPath] = [indexPath]
                if indexPath.row < self.chessEngine!.turnsCount() - 1 {
                    paths.append(IndexPath(row: row+1, section: 0))
                }
                self.notationTable?.reloadRows(at: paths, with: .fade)
            })
        case .next:
            control.isUserInteractionEnabled = false
            chessEngine?.turnForward({ next in
                control.isUserInteractionEnabled = true
                let row = self.chessEngine!.currentIndex() > 0 ? (self.chessEngine!.currentIndex() - 1)/2 : 0
                let indexPath = IndexPath(row: row, section: 0)
                if let visible = self.notationTable?.indexPathsForVisibleRows {
                    if visible.index(of: indexPath) == nil {
                        self.notationTable?.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                    }
                }
                var paths:[IndexPath] = [indexPath]
                if indexPath.row > 0 {
                    paths.append(IndexPath(row: row-1, section: 0))
                }
                self.notationTable?.reloadRows(at: paths, with: .fade)
            })
        }
    }
    
    func youWin() {
        if onlineGame != nil {
            showMessage("Congratilations, you are win!", messageType: .information, messageHandler: {
                self.goBack()
            })
        } else {
            showMessage("Congratilations, you are win!", messageType: .information)
        }
    }
    
    func showTable() {
        let wasHidden = self.notationTable!.isHidden
        let frame = wasHidden ?
            CGRect(x: self.view.frame.size.width - 200, y: 0, width: 200, height: self.view.frame.size.height) :
            CGRect(x: self.view.frame.size.width, y: 0, width: 200, height: self.view.frame.size.height)
        if wasHidden {
            self.notationTable!.isHidden = false
        }
        UIView.animate(withDuration: 0.4, animations: {
            self.notationTable?.frame = frame
        }, completion: { _ in
            if !wasHidden {
                self.notationTable!.isHidden = true
            }
        })
    }
    
    func didSetCurrentTurn(_ number:Int, white:Bool) {
        showTable()
        var index = number*2;
        if white {
            index += 1
        } else {
            index += 2
        }
        chessEngine?.play(to: index)
    }
    
    func gameNotify(_ notify:Notification) {
        let type = notify.object as! GamePush
        if type == .turn {
            Model.shared.lastMove(gameId: onlineGame!["uid"]!, move: { move in
                if move != nil {
                    self.chessEngine?.makeOnlineMove(move!)
                    self.status?.title = "You need make move"
                } else {
                    self.showMessage("Can not read move.", messageType: .error)
                }
            })
        } else if type == .surrender {
            youWin()
        }
    }
    
    func sendTurn(_ notify:Notification) {
        if let turn = notify.object as? String {
            onlineGame!["turn"] = turn
            SVProgressHUD.show(withStatus: "Send...")
            Model.shared.pushGame(to: partner!, type: .turn, game: onlineGame!, error: { error in
                SVProgressHUD.dismiss()
                if error != nil {
                    self.showMessage(error!.localizedDescription, messageType: .error)
                } else {
                    self.status?.title = "Waiting move from \(self.partner!.name!)"
                }
            })
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "white" {
            whiteEat = segue.destination as? EatController
        }
        if segue.identifier == "black" {
            blackEat = segue.destination as? EatController
        }
    }

}

extension BoardController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chessEngine!.turnsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "notationCell") as? TurnCell
        if cell == nil {
            cell = TurnCell(style: .default, reuseIdentifier: "notationCell")
            cell?.delegate = self
        }
        
        cell?.setTurn(number: indexPath.row,
                      white: chessEngine!.turnText(forRow: indexPath.row, white: true),
                      black: chessEngine!.turnText(forRow: indexPath.row, white: false)
        )
        
        let row = chessEngine!.currentIndex() > 0 ? (chessEngine!.currentIndex() - 1) / 2 : -1
        if (indexPath.row == row) {
            cell?.currentTurn = (chessEngine!.currentIndex() % 2) == 1
        } else {
            cell?.currentTurn = nil
        }
        return cell!
    }
}

extension BoardController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

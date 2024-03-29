//
//  LoginController.swift
//  v-Channel
//
//  Created by Сергей Сейтов on 22.02.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class LoginController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, TextFieldContainerDelegate {

    @IBOutlet weak var userField: TextFieldContainer!
    @IBOutlet weak var passwordField: TextFieldContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle("Authentication")
        setupBackButton()

        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
   
        userField.textType = .emailAddress
        userField.placeholder = "email"
        userField.returnType = .next
        userField.delegate = self
        
        passwordField.placeholder = "password"
        passwordField.returnType = .go
        passwordField.secure = true
        passwordField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.view.addGestureRecognizer(tap)
    }

    override func goBack() {
        self.navigationController?.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }

    func didLogin() {
        Model.shared.startObservers()
        super.goBack()
    }
    
    @objc func tap() {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func textDone(_ sender:TextFieldContainer, text:String?) {
        if sender == userField {
            if userField.text().isEmail() {
                passwordField.activate(true)
            } else {
                showMessage("Email should have xxxx@domain.prefix format.", messageType: .error, messageHandler: {
                    self.userField.activate(true)
                })
            }
        } else {
            if passwordField.text().isEmpty {
                showMessage("Password field required.", messageType: .error, messageHandler: {
                    self.passwordField.activate(true)
                })
            } else if userField.text().isEmpty {
                userField.activate(true)
            } else {
                emailAuth(user: userField.text(), password: passwordField.text())
            }
        }
    }
    
    func textChange(_ sender:TextFieldContainer, text:String?) -> Bool {
        return true
    }
    
    // MARK: - Facebook Auth
    
    @IBAction func facebookSignIn(_ sender: Any) { // read_custom_friendlists
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile","email"], from: self, handler: { result, error in
            if error != nil {
                self.showMessage("Facebook authorization error.", messageType: .error)
                return
            }
            
            SVProgressHUD.show(withStatus: "Login...") // interested_in
            let params = ["fields" : "name,email,picture.width(100).height(100)"]
            let request = FBSDKGraphRequest(graphPath: "me", parameters: params)
            request!.start(completionHandler: { _, result, fbError in
                if fbError != nil {
                    SVProgressHUD.dismiss()
                    self.showMessage(fbError!.localizedDescription, messageType: .error)
                } else {
                    print(FBSDKAccessToken.current().tokenString)
                    UserDefaults.standard.set(FBSDKAccessToken.current().tokenString, forKey: "fbToken")
                    UserDefaults.standard.synchronize()
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    Auth.auth().signIn(with: credential, completion: { firUser, error in
                        if error != nil {
                            SVProgressHUD.dismiss()
                            self.showMessage((error as NSError?)!.localizedDescription, messageType: .error)
                        } else {
                            if let profile = result as? [String:Any] {
                                Model.shared.createFacebookUser(firUser!, profile: profile, completion: {
                                    SVProgressHUD.dismiss()
                                    self.didLogin()
                                })
                            } else {
                                self.showMessage("Can not read user profile.", messageType: .error)
                                try? Auth.auth().signOut()
                            }
                        }
                    })
                }
            })
        })
    }
    
    // MARK: - Google+ Auth
    
    @IBAction func googleSitnIn(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            showMessage(error.localizedDescription, messageType: .error)
            return
        }
        let authentication = user.authentication
        let credential = GoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                          accessToken: (authentication?.accessToken)!)
        SVProgressHUD.show(withStatus: "Login...")
        Auth.auth().signIn(with: credential, completion: { firUser, error in
            if error != nil {
                SVProgressHUD.dismiss()
                self.showMessage((error as NSError?)!.localizedDescription, messageType: .error)
            } else {
                Model.shared.createGoogleUser(firUser!, googleProfile: user.profile, completion: {
                    SVProgressHUD.dismiss()
                    self.didLogin()
                })
            }
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        try? Auth.auth().signOut()
    }

    // MARK: - Email Auth
    
    func emailAuth(user:String, password:String) {
        SVProgressHUD.show(withStatus: "Login...")
        Auth.auth().signIn(withEmail: user, password: password, completion: { firUser, error in
            if error != nil {
                let err = error as NSError?
                SVProgressHUD.dismiss()
                if let reason = err!.userInfo["error_name"] as? String  {
                    if reason == "ERROR_USER_NOT_FOUND" {
                        self.performSegue(withIdentifier: "signUp", sender: nil)
                    } else {
                        self.showMessage(error!.localizedDescription, messageType: .error)
                    }
                } else {
                    self.showMessage(error!.localizedDescription, messageType: .error)
                }
            } else {
                if firUser!.isEmailVerified || testUser(user) {
                    Model.shared.uploadUser(firUser!.uid, result: { user in
                        SVProgressHUD.dismiss()
                        if user != nil {
                            self.didLogin()
                        } else {
                            self.showMessage("Can not download profile data.", messageType: .error)
                        }
                    })
                } else {
                    SVProgressHUD.dismiss()
                    self.showMessage("You must confirm your registeration. Check your mailbox and try again.", messageType: .information)
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signUp" {
            let next = segue.destination as! SignUpController
            next.userName = userField.text()
            next.userPassword = passwordField.text()
        }
    }

}

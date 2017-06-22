//
//  LoginViewController.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/22/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import UIKit
import GGLSignIn
import GoogleSignIn
import RxSwift

class LoginViewController: UIViewController {
    
    @IBOutlet var signInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes.append("https://picasaweb.google.com/data/")
        GIDSignIn.sharedInstance().signInSilently()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signIn(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
}

extension LoginViewController: GIDSignInUIDelegate {
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            let userId = user.userID
            let idToken = user.authentication.idToken
            print("===== \(user.authentication.accessToken)")
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            print("======================\(user.profile.imageURL(withDimension: 120))")
            print("======================\(user.accessibleScopes)")
            print(userId ?? "", idToken ?? "", fullName ?? "", givenName ?? "", familyName ?? "", email ?? "")
            (UIApplication.shared.delegate as! AppDelegate).showMain()
        } else {
            print("\(error.localizedDescription)")
        }
    }
}

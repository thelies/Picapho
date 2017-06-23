//
//  UserViewController.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/23/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import UIKit
import SDWebImage
import GoogleSignIn
import RealmSwift

class UserViewController: UIViewController {

    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var signOutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        settingUI()
    }
    
    func settingUI() {
        let userProfile = GIDSignIn.sharedInstance().currentUser.profile
        let iconURL = userProfile?.imageURL(withDimension: 100)
        let name = userProfile?.name
        let email = userProfile?.email
        avatarImage.sd_setImage(with: iconURL)
        nameLabel.text = name
        emailLabel.text = email
        signOutButton.setTitle("Sign out", for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func signOut(_ sender: Any) {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        GIDSignIn.sharedInstance().signOut()
        (UIApplication.shared.delegate as! AppDelegate).showLogin()
    }
}

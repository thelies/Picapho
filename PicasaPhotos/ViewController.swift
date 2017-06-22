//
//  ViewController.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/21/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import UIKit
import GGLSignIn
import GoogleSignIn
import RxSwift
import RxDataSources

class ViewController: UIViewController {

    @IBOutlet var signInOutButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var viewModel = AlbumListViewModel()
    let dataSource = RxTableViewSectionedAnimatedDataSource<AlbumSection>()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitles()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes.append("https://picasaweb.google.com/data/")
        GIDSignIn.sharedInstance().signInSilently()
        
        tableView.register(UINib(nibName: AlbumCell.identifier, bundle: nil), forCellReuseIdentifier: AlbumCell.identifier)
        tableView.estimatedRowHeight = 130
        tableView.rowHeight = UITableViewAutomaticDimension
        configDataSource()
        bind()
    }
    
    func configDataSource() {
        dataSource.configureCell = { (ds, tv, ip, item) in
            let cell = tv.dequeueReusableCell(withIdentifier: AlbumCell.identifier) as! AlbumCell
            cell.viewModel = AlbumViewModel(album: item)
            cell.bind()
            return cell
        }
    }
    
    func bind() {
        viewModel.albums
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInOut(_ sender: Any) {
        if let _ = GIDSignIn.sharedInstance().currentUser {
            GIDSignIn.sharedInstance().signOut()
            setTitles()
        } else {
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    func setTitles() {
        if let user = GIDSignIn.sharedInstance().currentUser {
            signInOutButton.setTitle("Sign Out", for: .normal)
            titleLabel.text = "Hello, \(user.profile.name ?? "")!"
        } else {
            signInOutButton.setTitle("Sign In", for: .normal)
            titleLabel.text = "Please sign in!"
        }
    }
}

extension ViewController: GIDSignInUIDelegate {
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            setTitles()
            let userId = user.userID
            let idToken = user.authentication.idToken
            print("===== \(user.authentication.accessToken)")
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            APIService.sharedInstance.fetchAlbumsList()
            print(userId ?? "", idToken ?? "", fullName ?? "", givenName ?? "", familyName ?? "", email ?? "")
        } else {
            print("\(error.localizedDescription)")
        }
    }
}


//
//  AlbumListViewController.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/23/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import UIKit
import GGLSignIn
import GoogleSignIn
import RxSwift
import RxDataSources

class AlbumListViewController: UIViewController {
    @IBOutlet var signOutButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var viewModel = AlbumListViewModel()
    let dataSource = RxTableViewSectionedAnimatedDataSource<AlbumSection>()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signOutButton.setTitle("Sign out", for: .normal)
        titleLabel.text = "Wellcome, \(GIDSignIn.sharedInstance().currentUser.profile.name!)!"
        tableView.register(UINib(nibName: AlbumCell.identifier, bundle: nil), forCellReuseIdentifier: AlbumCell.identifier)
        tableView.estimatedRowHeight = 130
        tableView.rowHeight = UITableViewAutomaticDimension
        configDataSource()
        bind()
        APIService.sharedInstance.fetchAlbumsList()
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
    }
    
    @IBAction func signOut(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        (UIApplication.shared.delegate as! AppDelegate).showLogin()
    }
}
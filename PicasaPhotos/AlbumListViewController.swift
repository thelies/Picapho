//
//  AlbumListViewController.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/23/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import PKHUD

class AlbumListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    var viewModel = AlbumListViewModel()
    let dataSource = RxTableViewSectionedAnimatedDataSource<AlbumSection>()
    let disposeBag = DisposeBag()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: AlbumCell.identifier, bundle: nil), forCellReuseIdentifier: AlbumCell.identifier)
        tableView.estimatedRowHeight = 130
        tableView.rowHeight = UITableViewAutomaticDimension
        addRefreshControl()
        configDataSource()
        bind()
        HUD.show(.progress)
        viewModel.fetchAlbums()
            .subscribe(
                onNext: { _ in
                    HUD.hide()
                    print("request success")
                }, onError: { [weak self] error in
                    HUD.hide()
                    let code = (error as NSError).code
                    let errorMessage = ErrorCode(rawValue: code)?.description() ?? ""
                    self?.presentErrorMessage(title: errorMessage)
                    print("code: \(code)")
            })
            .addDisposableTo(disposeBag)
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
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                let cell = self?.tableView.cellForRow(at: indexPath) as! AlbumCell
                let albumViewController = self?.storyboard?.instantiateViewController(withIdentifier: AlbumViewController.identifier) as! AlbumViewController
                albumViewController.viewModel = cell.viewModel
                self?.navigationController?.pushViewController(albumViewController, animated: true)
            })
            .addDisposableTo(disposeBag)
    }
    
    func addRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refresh() {
        viewModel.fetchAlbums()
            .subscribe(
                onNext: { [weak self] _ in
                    self?.refreshControl.endRefreshing()
                }, onError: { [weak self] error in
                    self?.refreshControl.endRefreshing()
                    let code = (error as NSError).code
                    let errorMessage = ErrorCode(rawValue: code)?.description() ?? ""
                    self?.presentErrorMessage(title: errorMessage)
                    print("code: \(code)")
            })
            .addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Resources in Album List: \(RxSwift.Resources.total)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

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

class AlbumListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    var viewModel = AlbumListViewModel()
    let dataSource = RxTableViewSectionedAnimatedDataSource<AlbumSection>()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: AlbumCell.identifier, bundle: nil), forCellReuseIdentifier: AlbumCell.identifier)
        tableView.estimatedRowHeight = 130
        tableView.rowHeight = UITableViewAutomaticDimension
        configDataSource()
        bind()
        viewModel.fetchAlbums()
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
            .map { [unowned self] indexPath in
                try! self.dataSource.model(at: indexPath) as! Album
            }
            .subscribe(onNext: { [unowned self] album in
                let albumViewController = self.storyboard?.instantiateViewController(withIdentifier: AlbumViewController.identifier) as! AlbumViewController
                albumViewController.viewModel = AlbumViewModel(album: album)
                self.navigationController?.pushViewController(albumViewController, animated: true)
            })
            .addDisposableTo(disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

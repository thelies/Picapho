//
//  PhotoListViewController.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/23/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class PhotoListViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    var viewModel = PhotoListViewModel()
    var dataSource = RxCollectionViewSectionedAnimatedDataSource<PhotoSection>()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: PhotoCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoCell.identifier)
        configDataSource()
        bind()
        viewModel.fetchPhotos()
    }
    
    func configDataSource() {
        dataSource.configureCell = { (ds, cv, ip, item) in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: ip) as! PhotoCell
            cell.viewModel = PhotoViewModel(photo: item)
            cell.bind()
            return cell
        }
    }
    
    func bind() {
        viewModel.photos
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        collectionView.rx.itemSelected
            .map { [weak self] indexPath in
                try! self?.dataSource.model(at: indexPath) as! Photo
            }
            .subscribe(onNext: { [weak self] photo in
                let photoViewController = self?.storyboard?.instantiateViewController(withIdentifier: PhotoViewController.identifier) as! PhotoViewController
                photoViewController.viewModel = PhotoViewModel(photo: photo)
                self?.navigationController?.pushViewController(photoViewController, animated: true)
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

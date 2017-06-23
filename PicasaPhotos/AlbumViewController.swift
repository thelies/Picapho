//
//  AlbumViewController.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/23/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import UIKit
import RxSwift

class AlbumViewController: UIViewController {

    static let identifier = "AlbumViewController"
    
    @IBOutlet var collectionView: UICollectionView!
    
    var viewModel: AlbumViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: PhotoCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoCell.identifier)
        settingUI()
        viewModel.fetchPhotos()
    }
    
    func settingUI() {
        viewModel.title.asDriver().drive(self.navigationItem.rx.title)
            .addDisposableTo(disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

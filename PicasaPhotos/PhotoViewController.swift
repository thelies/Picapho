//
//  PhotoViewController.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/23/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import UIKit
import RxSwift

class PhotoViewController: UIViewController {
    
    static let identifier = "PhotoViewController"

    @IBOutlet var photoImage: UIImageView!
    
    var viewModel: PhotoViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    func bind() {
        viewModel.imageURL.asDriver().drive(onNext: { [weak self] url in
            self?.photoImage.sd_setImage(with: URL(string: url))
            })
            .addDisposableTo(disposeBag)
        viewModel.title.asDriver().drive(self.navigationItem.rx.title)
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

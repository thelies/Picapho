//
//  PhotoCell.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/23/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage

class PhotoCell: UICollectionViewCell {
    
    static let identifier = "PhotoCell"
    
    @IBOutlet var photoImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    var viewModel: PhotoViewModel?
    private var bag: DisposeBag?
    
    func bind() {
        bag = DisposeBag()
        viewModel?.thumbnailURL.asDriver().drive(onNext: { [weak self] url in
            self?.photoImage.sd_setImage(with: URL(string: url))
        }).addDisposableTo(bag!)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
        viewModel = nil
    }
}

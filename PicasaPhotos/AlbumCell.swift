//
//  AlbumCell.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/22/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage

class AlbumCell: UITableViewCell {
    
    static let identifier = "AlbumCell"

    @IBOutlet var albumImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    
    var viewModel: AlbumViewModel?
    private var bag: DisposeBag?
    let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setImageGradient()
    }
    
    func bind() {
        bag = DisposeBag()
        viewModel?.title.asDriver().drive(titleLabel.rx.text).addDisposableTo(bag!)
        viewModel?.numphotos.asDriver()
            .map { number in number > 1 ? "\(number) photos" : "\(number) photo"}
            .drive(subTitleLabel.rx.text)
            .addDisposableTo(bag!)
        viewModel?.imageURL.asDriver().drive(onNext: { [weak self] url in
            self?.albumImage.sd_setImage(with: URL(string: url))
        }).addDisposableTo(bag!)
    }
    
    func setImageGradient() {
        let colorTop = UIColor.clear.cgColor
        let colorBottom = UIColor.black.withAlphaComponent(0.6).cgColor
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.5, 1.0]
        self.albumImage.layer.addSublayer(gradientLayer)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
        viewModel = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
}

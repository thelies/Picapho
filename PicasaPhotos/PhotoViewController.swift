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
        addSaveButton()
        bind()
    }
    
    func bind() {
        viewModel.imageURL.asDriver().drive(onNext: { [weak self] url in
            self?.photoImage.sd_setImage(with: URL(string: url))
            })
            .addDisposableTo(disposeBag)
        viewModel.title.asDriver().drive(self.navigationItem.rx.title)
            .addDisposableTo(disposeBag)
        
        ReachabilityService.sharedInstance.reachable.asObservable()
            .subscribe(onNext: { [weak self] isNetworkAvailable in
                if !isNetworkAvailable {
                    self?.presentErrorMessage(title: NetworkNotAvailable)
                }
            })
            .addDisposableTo(disposeBag)
    }

    func addSaveButton() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveButton
    }

    func save() {
        UIImageWriteToSavedPhotosAlbum(photoImage.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "New image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

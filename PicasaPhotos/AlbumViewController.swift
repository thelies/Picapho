//
//  AlbumViewController.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/23/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class AlbumViewController: UIViewController {

    static let identifier = "AlbumViewController"
    
    @IBOutlet var collectionView: UICollectionView!
    
    var viewModel: AlbumViewModel!
    var dataSource = RxCollectionViewSectionedAnimatedDataSource<PhotoSection>()
    let disposeBag = DisposeBag()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        addUploadButton()
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
        viewModel.title.asDriver().drive(self.navigationItem.rx.title)
            .addDisposableTo(disposeBag)
        
        viewModel.photos.asObservable()
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
    
    func addUploadButton() {
        let uploadButton = UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(upload))
        navigationItem.rightBarButtonItem = uploadButton
    }
    
    func upload() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension AlbumViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            viewModel.uploadPhoto(image: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

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
import PKHUD

class PhotoListViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    var viewModel = PhotoListViewModel()
    var dataSource = RxCollectionViewSectionedAnimatedDataSource<PhotoSection>()
    let disposeBag = DisposeBag()
    let imagePicker = UIImagePickerController()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        addUploadButton()
        collectionView.register(UINib(nibName: PhotoCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoCell.identifier)
        addRefreshControl()
        configDataSource()
        bind()
        HUD.show(.progress)
        viewModel.fetchPhotos()
            .subscribe(
                onNext: { _ in
                    HUD.hide()
                    print("request success")
            }, onError: { error in
                HUD.hide()
                let code = (error as NSError).code
                print("code: \(code)")
            })
            .addDisposableTo(disposeBag)
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

    func addUploadButton() {
        let uploadButton = UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(upload))
        navigationItem.rightBarButtonItem = uploadButton
    }
    
    func upload() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func addRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    func refresh() {
        viewModel.fetchPhotos()
            .subscribe(
                onNext: { _ in
                    self.refreshControl.endRefreshing()
            }, onError: { error in
                self.refreshControl.endRefreshing()
                let code = (error as NSError).code
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

extension PhotoListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            HUD.show(.progress)
            viewModel.uploadPhoto(image: pickedImage)
                .subscribe(
                    onNext: { _ in
                        HUD.flash(.success, delay: 1.0)
                        print("request success")
                }, onError: { error in
                    HUD.show(.error)
                    HUD.hide(afterDelay: 2.0)
                    let code = (error as NSError).code
                    print("code: \(code)")
                })
                .addDisposableTo(disposeBag)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

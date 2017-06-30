//
//  PhotoViewController.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/23/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import UIKit
import RxSwift
import GoogleMaps

class PhotoViewController: UIViewController {
    
    static let identifier = "PhotoViewController"

    @IBOutlet var photoImage: UIImageView!
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var mapView: GMSMapView!
    
    var viewModel: PhotoViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.layer.cornerRadius = 5
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
        viewModel.geoLocation.asDriver().drive(onNext: { [weak self] geoValue in
                if geoValue == "" {
                    self?.mapView.isHidden = true
                    self?.placeLabel.text = "No information about location"
                } else {
                    self?.placeLabel.text = "Location"
                    let geo = geoValue.components(separatedBy: " ")
                    let lat = Double(geo[0]) ?? 0.0
                    let long = Double(geo[1]) ?? 0.0
                    self?.addLocation(lat: lat, long: long)
                }
            })
            .addDisposableTo(disposeBag)
        
        ReachabilityService.sharedInstance.reachable.asObservable()
            .subscribe(onNext: { [weak self] isNetworkAvailable in
                if !isNetworkAvailable {
                    self?.presentErrorMessage(title: NetworkNotAvailable)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func addLocation(lat: Double, long: Double) {
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 10.0)
        mapView.camera = camera
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.layer.cornerRadius = 5
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.clipsToBounds = true
        imageView.sd_setImage(with: URL(string: viewModel.thumbnailURL.value))
        marker.iconView = imageView
        marker.map = mapView
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

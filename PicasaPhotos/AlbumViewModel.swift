//
//  AlbumViewModel.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/22/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

class AlbumViewModel {
    let id = Variable<String>("")
    let title = Variable<String>("")
    let access = Variable<String>("")
    let numphotos = Variable<Int>(0)
    let imageURL = Variable<String>("")
    let photos = Variable<[PhotoSection]>([])
    
    private let disposeBag = DisposeBag()
    let album: Album
    
    init(album: Album) {
        self.album = album
        album.rx.observe(String.self, "id")
            .map { [unowned self] _ in self.album.id }.bind(to: self.id)
            .addDisposableTo(disposeBag)
        album.rx.observe(String.self, "title")
            .map { [unowned self] _ in self.album.title }.bind(to: self.title)
            .addDisposableTo(disposeBag)
        album.rx.observe(String.self, "access")
            .map { [unowned self] _ in self.album.access }.bind(to: self.access)
            .addDisposableTo(disposeBag)
        album.rx.observe(String.self, "numphotos")
            .map { [unowned self] _ in self.album.numphotos }.bind(to: self.numphotos)
            .addDisposableTo(disposeBag)
        album.rx.observe(String.self, "imageURL")
            .map { [unowned self] _ in self.album.imageURL }.bind(to: self.imageURL)
            .addDisposableTo(disposeBag)
        album.rx.observe(List<Photo>.self, "photos")
            .map { [unowned self] _ in
                var photos = [Photo]()
                for (_, photo) in self.album.photos.enumerated() {
                    photos.append(photo)
                }
                return [PhotoSection(model: "", items: photos)]
            }.bind(to: self.photos)
            .addDisposableTo(disposeBag)
    }
    
    func fetchPhotos() -> Observable<RequestResult> {
        return APIService.sharedInstance.fetchPhotosInAlbum(album: album)
    }
    
    func uploadPhoto(image: UIImage) -> Observable<RequestResult> {
        return APIService.sharedInstance.uploadPhoto(image: image, album: album)
    }
}

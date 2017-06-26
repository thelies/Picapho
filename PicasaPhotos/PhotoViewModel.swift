//
//  PhotoViewModel.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/23/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

class PhotoViewModel {
    let id = Variable<String>("")
    let title = Variable<String>("")
    let access = Variable<String>("")
    let imageURL = Variable<String>("")
    let thumbnailURL = Variable<String>("")
    let geoLocation = Variable<String>("")
    let published = Variable<String>("")
    let updated = Variable<String>("")
    
    private let disposeBag = DisposeBag()
    let photo: Photo
    
    init(photo: Photo) {
        self.photo = photo
        photo.rx.observe(String.self, "id")
            .map { [unowned self] _ in self.photo.id }.bind(to: self.id)
            .addDisposableTo(disposeBag)
        photo.rx.observe(String.self, "title")
            .map { [unowned self] _ in self.photo.title }.bind(to: self.title)
            .addDisposableTo(disposeBag)
        photo.rx.observe(String.self, "access")
            .map { [unowned self] _ in self.photo.access }.bind(to: self.access)
            .addDisposableTo(disposeBag)
        photo.rx.observe(String.self, "imageURL")
            .map { [unowned self] _ in self.photo.imageURL }.bind(to: self.imageURL)
            .addDisposableTo(disposeBag)
        photo.rx.observe(String.self, "thumbnailURL")
            .map { [unowned self] _ in self.photo.thumbnailURL }.bind(to: self.thumbnailURL)
            .addDisposableTo(disposeBag)
        photo.rx.observe(String.self, "geoLocation")
            .map { [unowned self] _ in self.photo.geoLocation }.bind(to: self.geoLocation)
            .addDisposableTo(disposeBag)
        photo.rx.observe(String.self, "published")
            .map { [unowned self] _ in self.photo.published }.bind(to: self.published)
            .addDisposableTo(disposeBag)
        photo.rx.observe(String.self, "updated")
            .map { [unowned self] _ in self.photo.updated }.bind(to: self.updated)
            .addDisposableTo(disposeBag)
    }
}

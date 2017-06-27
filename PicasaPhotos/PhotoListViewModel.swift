//
//  PhotoListViewModel.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/23/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxRealm
import RealmSwift

typealias PhotoSection = AnimatableSectionModel<String, Photo>

class PhotoListViewModel {
    var photos: Observable<[PhotoSection]> {
        return fetchPhotosFromDB()
            .map { results in
                return [PhotoSection(model: "", items: results.toArray())]
        }
    }
    
    func fetchPhotosFromDB() -> Observable<Results<Photo>> {
        let realm = try! Realm()
        let photos = realm.objects(Photo.self)
        return Observable.collection(from: photos)
    }
    
    func fetchPhotos() {
        APIService.sharedInstance.fetchPhotosList()
    }
    
    func uploadPhoto(image: UIImage) {
        APIService.sharedInstance.uploadPhoto(image: image, album: nil)
    }
}

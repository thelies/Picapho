//
//  AlbumListViewModel.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/22/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxRealm
import RealmSwift

typealias AlbumSection = AnimatableSectionModel<String, Album>

class AlbumListViewModel {
    var albums: Observable<[AlbumSection]> {
        return fetchAlbumsFromDB()
            .map { results in
                return [AlbumSection(model: "", items: results.toArray())]
        }
    }
    
    func fetchAlbumsFromDB() -> Observable<Results<Album>> {
        let realm = try! Realm()
        let albums = realm.objects(Album.self)
        return Observable.collection(from: albums)
    }
    
    func fetchAlbums() -> Observable<RequestResult> {
        return APIService.sharedInstance.fetchAlbumsList()
    }
}

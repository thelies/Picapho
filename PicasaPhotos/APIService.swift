//
//  APIService.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/22/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import Foundation
import Alamofire
import GoogleSignIn
import SWXMLHash
import RealmSwift

protocol APIServiceProtocol {
    func fetchAlbumsList()
    func fetchPhotosInAlbum(album: Album)
    func fetchPhotosList()
    func uploadPhoto(image: UIImage, album: Album?)
}

class APIService: APIServiceProtocol {
    static let sharedInstance = APIService()
    
    let baseURL = "https://picasaweb.google.com/data"
    let headers: HTTPHeaders = [
        "GData-Version": "3"
    ]

    var userID: String {
        return GIDSignIn.sharedInstance().currentUser.userID ?? "default"
    }
    var accessToken: String {
        return GIDSignIn.sharedInstance().currentUser.authentication.accessToken ?? ""
    }
    
    func fetchAlbumsList() {
        let url = "\(baseURL)/feed/api/user/\(userID)"
        let feedFields = "icon, openSearch:totalResults, openSearch:startIndex"
        let entryFields = "entry(title, gphoto:id, gphoto:numphotos, gphoto:access, media:group/media:content, media:group/media:thumbnail)"
        let params: Parameters = [
            "kind": "album",
            "access": "all",
            "access_token": "\(accessToken)",
            "fields": "\(feedFields),\(entryFields)",
        ]
        
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers)
            .response { response in
                let xmlsData = SWXMLHash.parse(response.data!)
                let feedData = xmlsData["feed"]
                let realm = try! Realm()
                try! realm.write {
                    for child in feedData.children {
                        if child.element?.name == "entry" {
                            let album = Album(indexer: child)
                            realm.add(album, update: true)
                        }
                    }
                }
        }
    }
    
    func fetchPhotosInAlbum(album: Album) {
        let url = "\(baseURL)/feed/api/user/\(userID)/albumid/\(album.id)"
        let feedFields = "icon, openSearch:totalResults, openSearch:startIndex"
        let entryFields = "entry(title, gphoto:id, gphoto:access, media:group/media:content, media:group/media:thumbnail, georss:where, published, updated)"
        let params: Parameters = [
            "kind": "photo",
            "access": "all",
            "access_token": "\(accessToken)",
            "fields": "\(feedFields),\(entryFields)",
            "max-results": 100
        ]
        
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers)
            .response { response in
                let xmlsData = SWXMLHash.parse(response.data!)
                let feedData = xmlsData["feed"]
                let realm = try! Realm()
                try! realm.write {
                    for child in feedData.children {
                        if child.element?.name == "entry" {
                            let photo = Photo(indexer: child)
                            realm.add(photo, update: true)
                            if !album.photos.contains(photo) {
                                album.photos.append(photo)
                            }
                        }
                    }
                    realm.add(album, update: true)
                }
        }
    }
    
    func fetchPhotosList() {
        let url = "\(baseURL)/feed/api/user/\(userID)"
        let feedFields = "icon, openSearch:totalResults, openSearch:startIndex"
        let entryFields = "entry(title, gphoto:id, gphoto:access, media:group/media:content, media:group/media:thumbnail, georss:where, published, updated)"
        let params: Parameters = [
            "kind": "photo",
            "access": "all",
            "access_token": "\(accessToken)",
            "fields": "\(feedFields),\(entryFields)",
            "max-results": 20
        ]
        
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers)
            .response { response in
                let xmlsData = SWXMLHash.parse(response.data!)
                let feedData = xmlsData["feed"]
                let realm = try! Realm()
                try! realm.write {
                    for child in feedData.children {
                        if child.element?.name == "entry" {
                            let photo = Photo(indexer: child)
                            realm.add(photo, update: true)
                        }
                    }
                }
        }
    }
    
    func uploadPhoto(image: UIImage, album: Album?) {
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let albumID = album?.id ?? "default"
        let url = "\(baseURL)/feed/api/user/\(userID)/albumid/\(albumID)?access_token=\(accessToken)"
        var newHeaders = headers
        newHeaders["Content-Type"] = "image/jpeg"
        newHeaders["Content-Length"] = "\(imageData!.count)"
        newHeaders["Slug"] = "\(generateNameByDate(date: Date()))"

        Alamofire.upload(imageData!, to: url, method: .post, headers: newHeaders).response { response in
            let xmlsData = SWXMLHash.parse(response.data!)
            let feedData = xmlsData["entry"]
            let realm = try! Realm()
            try! realm.write {
                let photo = Photo(indexer: feedData)
                realm.add(photo, update: true)
                if let album = album, !album.photos.contains(photo) {
                    album.photos.append(photo)
                    album.numphotos += 1
                    realm.add(album, update: true)
                }
            }
        }
    }
}

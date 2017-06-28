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
import RxSwift

enum RequestResult {
    case Success
    case Error(NSError)
}

protocol APIServiceProtocol {
    func fetchAlbumsList() -> Observable<RequestResult>
    func fetchPhotosInAlbum(album: Album) -> Observable<RequestResult>
    func fetchPhotosList() -> Observable<RequestResult>
    func uploadPhoto(image: UIImage, album: Album?) -> Observable<RequestResult>
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
    
    func request(url: URLConvertible, method: HTTPMethod, parameters: Parameters, headers: HTTPHeaders) -> Observable<XMLIndexer> {
        return Observable.create { observer in
            Alamofire.request(url, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers)
                .validate(statusCode: 200..<500)
                .responseData { response in
                    if let responseCode = response.response?.statusCode {
                        switch responseCode {
                        case 200..<300:
                            let xmlData = SWXMLHash.parse(response.data!)
                            observer.onNext(xmlData)
                            observer.onCompleted()
                        default:
                            observer.onError(Util.ErrorWithResponseStatusCode(statusCode: responseCode))
                        }
                    }
            }
            return Disposables.create()
        }
    }
    
    func upload(data: Data, to: URLConvertible, method: HTTPMethod, headers: HTTPHeaders) -> Observable<XMLIndexer> {
        return Observable.create { observer in
            Alamofire.upload(data, to: to, method: method, headers: headers)
                .validate(statusCode: 200..<500)
                .responseData { response in
                    if let responseCode = response.response?.statusCode {
                        switch responseCode {
                        case 200..<300:
                            let xmlData = SWXMLHash.parse(response.data!)
                            observer.onNext(xmlData)
                            observer.onCompleted()
                        default:
                            observer.onError(Util.ErrorWithResponseStatusCode(statusCode: responseCode))
                        }
                    }
            }
            return Disposables.create()
        }
    }
    
    func fetchAlbumsList() -> Observable<RequestResult> {
        let url = "\(baseURL)/feed/api/user/\(userID)"
        let feedFields = "icon, openSearch:totalResults, openSearch:startIndex"
        let entryFields = "entry(title, gphoto:id, gphoto:numphotos, gphoto:access, media:group/media:content, media:group/media:thumbnail)"
        let params: Parameters = [
            "kind": "album",
            "access": "all",
            "access_token": "\(accessToken)",
            "fields": "\(feedFields),\(entryFields)",
        ]
        
        return request(url: url, method: .get, parameters: params, headers: headers)
            .map { data -> RequestResult in
                let feedData = data["feed"]
                let realm = try! Realm()
                try! realm.write {
                    for child in feedData.children {
                        if child.element?.name == "entry" {
                            let album = Album(indexer: child)
                            realm.add(album, update: true)
                        }
                    }
                }
                
                return RequestResult.Success
            }
    }
    
    func fetchPhotosInAlbum(album: Album) -> Observable<RequestResult> {
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
        
        return request(url: url, method: .get, parameters: params, headers: headers)
            .map { data -> RequestResult in
                let feedData = data["feed"]
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
                
                return RequestResult.Success
            }
    }
    
    func fetchPhotosList() -> Observable<RequestResult> {
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
        
        return request(url: url, method: .get, parameters: params, headers: headers)
            .map { data -> RequestResult in
                let feedData = data["feed"]
                let realm = try! Realm()
                try! realm.write {
                    for child in feedData.children {
                        if child.element?.name == "entry" {
                            let photo = Photo(indexer: child)
                            realm.add(photo, update: true)
                        }
                    }
                }
                
                return RequestResult.Success
            }
    }
    
    func uploadPhoto(image: UIImage, album: Album?) -> Observable<RequestResult> {
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let albumID = album?.id ?? "default"
        let url = "\(baseURL)/feed/api/user/\(userID)/albumid/\(albumID)?access_token=\(accessToken)"
        var newHeaders = headers
        newHeaders["Content-Type"] = "image/jpeg"
        newHeaders["Content-Length"] = "\(imageData!.count)"
        newHeaders["Slug"] = "\(generateNameByDate(date: Date()))"
        
        return upload(data: imageData!, to: url, method: .post, headers: newHeaders)
            .map { data -> RequestResult in
                let feedData = data["entry"]
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
                
                return RequestResult.Success
            }
    }

}

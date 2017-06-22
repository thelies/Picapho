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
    func fetchPhotosList()
    // Create Album
    // Upload Image
    // Download Image
}

class APIService: APIServiceProtocol {
    static let sharedInstance = APIService()
    
    let baseURL = "https://picasaweb.google.com/data"
    let userID = GIDSignIn.sharedInstance().currentUser.userID ?? "default"
    let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken ?? ""
    let headers: HTTPHeaders = [
        "GData-Version": "3"
    ]
    
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
                            realm.create(Album.self, value: album, update: true)
                        }
                    }
                }
        }
    }
    
    func fetchPhotosList() {
    }
}
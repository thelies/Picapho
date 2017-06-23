//
//  Photo.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/23/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import Foundation
import RealmSwift
import SWXMLHash
import RxDataSources

class Photo: Object {
    dynamic var id = ""
    dynamic var title = ""
    dynamic var access = ""
    dynamic var imageURL = ""
    dynamic var thumbnailURL = ""
    dynamic var geoLocation = ""
    dynamic var published = ""
    dynamic var updated = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }

    required convenience init(indexer: XMLIndexer) {
        self.init()
        self.id = indexer["gphoto:id"].element!.text
        self.title = indexer["title"].element!.text
        self.access = indexer["gphoto:access"].element!.text
        self.imageURL = indexer["media:group"]["media:content"].element?.attribute(by: "url")?.text ?? ""
        self.thumbnailURL = indexer["media:group"]["media:thumbnail"][1].element?.attribute(by: "url")?.text ?? ""
        self.geoLocation = indexer["georss:where"]["gml:Point"]["gml:pos"].element?.text ?? ""
        self.published = indexer["published"].element!.text
        self.updated = indexer["updated"].element!.text
    }
}

//
//  Album.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/22/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import Foundation
import RealmSwift
import SWXMLHash

class Album: Object {
    dynamic var id = ""
    dynamic var title = ""
    dynamic var access = ""
    dynamic var numphotos = 0
    dynamic var thumbnailURL = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init(indexer: XMLIndexer) {
        self.init()
        self.id = indexer["gphoto:id"].element!.text
        self.title = indexer["title"].element!.text
        self.access = indexer["gphoto:access"].element!.text
        self.numphotos = Int(indexer["gphoto:numphotos"].element!.text)!
        self.thumbnailURL = indexer["media:group"]["media:thumbnail"].element!.attribute(by: "url")!.text
    }
}

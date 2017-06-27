//
//  StoryboardUtil.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/22/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import UIKit

class StoryboardUtil {
    class var mainStoryboard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    class var loginStoryboard: UIStoryboard {
        return UIStoryboard(name: "Login", bundle: nil)
    }
}

func generateNameByDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd_hhmmss"
    return dateFormatter.string(from: date)
}

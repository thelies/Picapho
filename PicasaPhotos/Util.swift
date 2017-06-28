//
//  Util.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/27/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import Foundation

class Util {
    class func generateNameByDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_hhmmss"
        return dateFormatter.string(from: date)
    }
    
    class func ErrorWithResponseStatusCode(statusCode : Int) -> NSError {
        var error = NSError(domain: DomainError, code:statusCode, userInfo: nil)
        
        switch statusCode {
        case 400:
            error = BadRequestError
        case 401:
            error = UnauthorizedError
        case 403:
            error = ForbiddenError
        case 404:
            error = NotFoundError
        default:
            error = NSError(domain: DomainError, code:statusCode, userInfo: nil)
        }
        
        return error
    }
}

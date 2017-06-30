//
//  Constant.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/27/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import Foundation

enum ErrorCode: Int {
    case BadRequest = 400
    case Unauthorized = 401
    case Forbidden = 403
    case NotFound = 404
    
    func description() -> String {
        switch self {
        case .BadRequest:
            return "Bad request error"
        case .Unauthorized:
            return "Unauthorized error"
        case .Forbidden:
            return "Forbidden error"
        case .NotFound:
            return "Not found error"
        }
    }
}

let DomainError = "PicasaPhotos"
let BadRequestError = NSError(domain: DomainError, code: 400, userInfo: nil)
let UnauthorizedError = NSError(domain: DomainError, code: 401, userInfo: nil)
let ForbiddenError = NSError(domain: DomainError, code: 403, userInfo: nil)
let NotFoundError = NSError(domain: DomainError, code: 404, userInfo: nil)
let NetworkNotAvailable = "Network connection is not available"

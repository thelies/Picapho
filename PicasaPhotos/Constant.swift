//
//  Constant.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/27/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import Foundation

let DomainError = "PicasaPhotos"
let BadRequestError = NSError(domain: DomainError, code: 400, userInfo: nil)
let UnauthorizedError = NSError(domain: DomainError, code: 401, userInfo: nil)
let ForbiddenError = NSError(domain: DomainError, code: 403, userInfo: nil)
let NotFoundError = NSError(domain: DomainError, code: 404, userInfo: nil)

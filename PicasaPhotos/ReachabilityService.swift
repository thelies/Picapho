//
//  ReachabilityService.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/30/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import Foundation
import ReachabilitySwift
import RxSwift

class ReachabilityService {
    static let sharedInstance = ReachabilityService()
    
    let reachable: Variable<Bool>
    private var reachability: Reachability!
    
    private init() {
        reachability = Reachability()!
        reachable = Variable(reachability.isReachable)
        
        reachability.whenReachable = { [unowned self] _ in
            self.reachable.value = true
        }
        
        reachability.whenUnreachable = { [unowned self] _ in
            self.reachable.value = false
        }
        
        try! reachability.startNotifier()
    }
}

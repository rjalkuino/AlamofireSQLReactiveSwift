//
//  SessionService.swift
//  AlamofireSQLReactiveSwift
//
//  Created by Robert John Alkuino on 3/27/20.
//  Copyright © 2020 Robert John Alkuino. All rights reserved.
//

import Foundation
import ReactiveSwift
import SQLite

class SessionService {
    
    private static var logoutCallbacks: [(performAlways: Bool, fn: () -> ())] = []
    
    static let loginNotifiaction = NotificationSignal<Void>()
    
    static func prepare() {
        //
    }
    
    static func logout() {
        for (_, fn) in logoutCallbacks {
            fn()
        }
        
        reset()
        
        logoutCallbacks = logoutCallbacks.filter { (performAlways, _) in performAlways }
    }
    
    static func onLogout(performAlways: Bool = false, fn: @escaping () -> ()) {
        logoutCallbacks.append((performAlways, fn))
    }
    
    
    static func reset() {
        
    }
}


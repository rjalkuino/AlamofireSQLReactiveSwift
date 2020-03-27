//
//  APIService.swift
//  AlamofireSQLReactiveSwift
//
//  Created by Robert John Alkuino on 3/27/20.
//  Copyright © 2020 Robert John Alkuino. All rights reserved.
//

import UIKit
import ObjectMapper
import Result


struct EmptyResponse: Mappable {
    init() {}
    init?(map: Map) {}
    mutating func mapping(map: Map) {}
}

struct ApiError: Error {
    
    static let Nil = ApiError(endpoint: "", timeout: false, status: nil, message: "", error: nil)
    
    let endpoint: String
    let timeout: Bool
    let status: Int?
    let message: String
    let error: Error?
    
    var suspicious: Bool {
        return status == 500 || status == -1
    }
}

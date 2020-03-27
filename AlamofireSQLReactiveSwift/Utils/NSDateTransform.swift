//
//  NSDateTransform.swift
//  AlamofireSQLReactiveSwift
//
//  Created by Robert John Alkuino on 3/27/20.
//  Copyright © 2020 Robert John Alkuino. All rights reserved.
//

import Foundation
import ObjectMapper

public class DateTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = String
    
    public func transformFromJSON(_ value: Any?) -> Date? {
        if let str = value as? String {
            return Date.fromRFC3339String(str: str)
        }
        return nil
    }
    
    public func transformToJSON(_ value: Date?) -> String? {
        if let date = value {
            return date.toRFC3339String()
        }
        return nil
    }
}

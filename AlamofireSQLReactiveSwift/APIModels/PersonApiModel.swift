//
//  PersonApiModel.swift
//  AlamofireSQLReactiveSwift
//
//  Created by Robert John Alkuino on 3/27/20.
//  Copyright © 2020 Robert John Alkuino. All rights reserved.
//

import Foundation
import ObjectMapper

struct PersonApiModel: ApiModel, Mappable {
    
    var ID: UUID = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var email: String? = nil
    var displayName: String = ""
    var userName: String = ""
    var text: String = ""
    var optographsCount: Int = 0
    var followersCount: Int = 0
    var followedCount: Int = 0
    var isFollowed: Bool = false
    var avatarAssetID: UUID = ""
    
    init() {}
    
    init?(map: Map){}
    
    mutating func mapping(map: Map) {
        ID                  <- map["id"]
        createdAt           <- (map["created_at"], DateTransform())
        updatedAt           <- (map["updated_at"], DateTransform())
        email               <- map["email"]
        displayName         <- map["display_name"]
        userName            <- map["user_name"]
        text                <- map["text"]
        optographsCount     <- map["optographs_count"]
        followersCount      <- map["followers_count"]
        followedCount       <- map["followed_count"]
        isFollowed          <- map["is_followed"]
        avatarAssetID       <- map["avatar_asset_id"]
    }
}

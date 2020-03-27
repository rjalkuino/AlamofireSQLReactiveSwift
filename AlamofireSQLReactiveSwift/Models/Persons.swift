//
//  Persons.swift
//  AlamofireSQLReactiveSwift
//
//  Created by Robert John Alkuino on 3/27/20.
//  Copyright © 2020 Robert John Alkuino. All rights reserved.
//

import ObjectMapper
import ReactiveSwift

struct Person: Model {
    var ID: UUID
    var createdAt: Date
    var updatedAt: Date
    var email: String?
    var displayName: String
    var userName: String
    var text: String
    var optographsCount: Int
    var followersCount: Int
    var followedCount: Int
    var isFollowed: Bool
    var avatarAssetID: UUID
    
    static let guestID: UUID = "00000000-0000-0000-0000-000000000000"
    
    static func newInstance() -> Person {
        return Person(
            ID: uuid(),
            createdAt: Date(),
            updatedAt: Date(),
            email: nil,
            displayName: "",
            userName: "",
            text: "",
            optographsCount: 0,
            followersCount: 0,
            followedCount: 0,
            isFollowed: false,
            avatarAssetID: ""
        )
    }
}

extension Person: MergeApiModel {
    typealias AM = PersonApiModel
    
    mutating func mergeApiModel(apiModel: PersonApiModel) {
        ID = apiModel.ID
        createdAt = apiModel.createdAt
        updatedAt = apiModel.updatedAt
        email = apiModel.email
        displayName = apiModel.displayName
        userName = apiModel.userName
        text = apiModel.text
        optographsCount = apiModel.optographsCount
        followersCount = apiModel.followersCount
        followedCount = apiModel.followedCount
        isFollowed = apiModel.isFollowed
        avatarAssetID = apiModel.avatarAssetID
    }
}

extension Person: Equatable {}

func ==(lhs: Person, rhs: Person) -> Bool {
    return lhs.ID == rhs.ID
        && lhs.createdAt == rhs.createdAt
        && lhs.updatedAt == rhs.updatedAt
        && lhs.email == rhs.email
        && lhs.displayName == rhs.displayName
        && lhs.userName == rhs.userName
        && lhs.optographsCount == rhs.optographsCount
        && lhs.followersCount == rhs.followersCount
        && lhs.followedCount == rhs.followedCount
        && lhs.isFollowed == rhs.isFollowed
        && lhs.avatarAssetID == rhs.avatarAssetID
}

extension Person: SQLiteModel {
    
    static func schema() -> ModelSchema {
        return PersonSchema
    }
    
    static func table() -> SQLiteTable {
        return PersonTable
    }
    
    static func fromSQL(row: SQLiteRow) -> Person {
        return Person(
            ID: row[PersonSchema.ID],
            createdAt: row[PersonSchema.createdAt],
            updatedAt: row[PersonSchema.updatedAt],
            email: row[PersonSchema.email],
            displayName: row[PersonSchema.displayName],
            userName: row[PersonSchema.userName],
            text: row[PersonSchema.text],
            optographsCount: row[PersonSchema.optographsCount],
            followersCount: row[PersonSchema.followersCount],
            followedCount: row[PersonSchema.followedCount],
            isFollowed: row[PersonSchema.isFollowed],
            avatarAssetID: row[PersonSchema.avatarAssetID]
        )
    }
    
    func toSQL() -> [SQLiteSetter] {
        var setters = [
            PersonSchema.ID <-- ID,
            PersonSchema.createdAt <-- createdAt,
            PersonSchema.updatedAt <-- updatedAt,
            PersonSchema.displayName <-- displayName,
            PersonSchema.userName <-- userName,
            PersonSchema.text <-- text,
            PersonSchema.optographsCount <-- optographsCount,
            PersonSchema.followersCount <-- followersCount,
            PersonSchema.followedCount <-- followedCount,
            PersonSchema.isFollowed <-- isFollowed,
            PersonSchema.avatarAssetID <-- avatarAssetID
        ]
        
        if email != nil {
            setters.append(PersonSchema.email <-- email)
        }
        
        return setters
    }
    
}

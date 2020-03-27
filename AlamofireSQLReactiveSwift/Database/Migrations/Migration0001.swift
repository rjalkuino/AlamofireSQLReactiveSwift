//
//  Migration0001.swift
//  AlamofireSQLReactiveSwift
//
//  Created by Robert John Alkuino on 3/27/20.
//  Copyright © 2020 Robert John Alkuino. All rights reserved.
//

import UIKit

import SQLite

func migration0001(db: Connection) throws {
    try db.run(createPerson())
}

private func createPerson() -> String {
    return PersonTable.create { t in
        t.column(PersonSchema.ID, primaryKey: true)
        t.column(PersonSchema.email)
        t.column(PersonSchema.displayName)
        t.column(PersonSchema.userName)
        t.column(PersonSchema.text)
        t.column(PersonSchema.followersCount)
        t.column(PersonSchema.followedCount)
        t.column(PersonSchema.isFollowed)
        t.column(PersonSchema.createdAt)
        t.column(PersonSchema.avatarAssetID)
    }
}

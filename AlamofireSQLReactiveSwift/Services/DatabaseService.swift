//
//  DatabaseService.swift
//  AlamofireSQLReactiveSwift
//
//  Created by Robert John Alkuino on 3/27/20.
//  Copyright © 2020 Robert John Alkuino. All rights reserved.
//

import Foundation
import SQLite
import ReactiveSwift

protocol ModelSchema {
    var ID: Expression<UUID> { get }
}

protocol SQLiteModel {
    var ID: UUID { get set }
    static func fromSQL(row: SQLiteRow) -> Self
    static func table() -> SQLiteTable
    static func schema() -> ModelSchema
    func toSQL() -> [Setter]
    func insertOrUpdate() throws
}

extension SQLiteModel {
    
    func insertOrUpdate() throws {
        let setters = toSQL()
        let table = Self.table()
        do {
            try DatabaseService.defaultConnection.run(table.insert(or: .fail, setters))
        } catch {
            let rowsChanged = try DatabaseService.defaultConnection.run(table.filter(table[Self.schema().ID] ==- ID).update(setters))
            if rowsChanged != 1 {
                throw DatabaseQueryError.NotFound
            }
        }
    }
    
    func insertOrIgnore() {
        let setters = toSQL()
        let table = Self.table()
        do {
            try DatabaseService.defaultConnection.run(table.insert(or: .fail, setters))
        } catch {}
    }
    
}

extension Date {
    static var declaredDatatype: String {
        return String.declaredDatatype
    }
    static func fromDatatypeValue(stringValue: String) -> Date {
        return Date.fromRFC3339String(str: stringValue)!
    }
    var datatypeValue: String {
        return toRFC3339String()
    }
}

enum DatabaseQueryType {
    case One
    case Many
}

enum DatabaseQueryError: Error {
    case NotFound
    case Nil
}

class DatabaseService {
    
    static var defaultConnection: Connection!
    
    private static let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/database.sqlite3"
    private static let migrations = [
        migration0001
    ]
    
    static func prepare() throws {
        // set database connection instance
        defaultConnection = try Connection(path)
        
        // enable console logging
//        defaultConnection.trace { msg in print("\(msg)\n") }
        
        try migrate()
        
        SessionService.onLogout(performAlways: true) { try! reset(ephemeralTables: []) }
    }
    
    static func reset(ephemeralTables:[Table]) throws {
        
        for ephemeralTable in ephemeralTables {
            try defaultConnection.run(ephemeralTable.delete())
        }
        
        let personsToDelete = PersonTable.filter(PersonSchema.ID != Person.guestID)
        try defaultConnection.run(personsToDelete.delete())
    }
    
    static func query(type: DatabaseQueryType, query: Table) -> SignalProducer<Row, DatabaseQueryError> {
        
        
        
        return SignalProducer { sink,disposable in
            
            switch type {
            case .One:
                guard let row = try! DatabaseService.defaultConnection.pluck(query) else {
                    sink.send(error: .NotFound)
                    break
                }
                sink.send(value: row)
            case .Many:
                for row in try! DatabaseService.defaultConnection.prepare(query) {
                    sink.send(value: row)
                }
            }
            sink.sendCompleted()
        }
    }
    
    private static func migrate() throws {
        var userVersion = defaultConnection.userVersion
        for (index, migration) in migrations.enumerated() {
            let migrationVersion = index + 1
            if userVersion < migrationVersion {
                try defaultConnection.transaction {
                    try migration(defaultConnection)
                    defaultConnection.userVersion = migrationVersion
                }
                userVersion = migrationVersion
                print("Migrated database to version \(migrationVersion)")
            }
        }
    }
    
}

typealias SQLiteRow = SQLite.Row
typealias SQLiteTable = SQLite.Table
typealias SQLiteSetter = SQLite.Setter
typealias SQLiteValue = SQLite.Value

extension Connection {
    public var userVersion: Int {
        get { return try! Int(scalar("PRAGMA user_version") as! Int64) }
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
}

infix operator <-- : Equivalence

precedencegroup Equivalence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
    assignment: true
}

public func <--<V : Value>(column: Expression<V>, value: Expression<V>) -> Setter {
    return column <- value
}
public func <--<V : Value>(column: Expression<V>, value: V) -> Setter {
    return column <- value
}
public func <--<V : Value>(column: Expression<V?>, value: Expression<V>) -> Setter {
    return column <- value
}
public func <--<V : Value>(column: Expression<V?>, value: Expression<V?>) -> Setter {
    return column <- value
}
public func <--<V : Value>(column: Expression<V?>, value: V?) -> Setter {
    return column <- value
}

infix operator ==- : ComparisonPrecedence

precedencegroup ComparisonPrecedence {
  associativity: left
  higherThan: LogicalConjunctionPrecedence
}

public func ==-<V : Value>(lhs: Expression<V>, rhs: Expression<V>) -> Expression<Bool> where V.Datatype : Equatable {
    return lhs == rhs
}
public func ==-<V : Value>(lhs: Expression<V>, rhs: Expression<V?>) -> Expression<Bool?> where V.Datatype : Equatable {
    return lhs == rhs
}
public func ==-<V : Value>(lhs: Expression<V?>, rhs: Expression<V>) -> Expression<Bool?> where V.Datatype : Equatable {
    return lhs == rhs
}
public func ==-<V : Value>(lhs: Expression<V?>, rhs: Expression<V?>) -> Expression<Bool?> where V.Datatype : Equatable {
    return lhs == rhs
}
public func ==-<V : Value>(lhs: Expression<V>, rhs: V) -> Expression<Bool> where V.Datatype : Equatable {
    return lhs == rhs
}
public func ==-<V : Value>(lhs: Expression<V?>, rhs: V?) -> Expression<Bool?> where V.Datatype : Equatable {
    return lhs == rhs
}
public func ==-<V : Value>(lhs: V, rhs: Expression<V>) -> Expression<Bool> where V.Datatype : Equatable {
    return lhs == rhs
}
public func ==-<V : Value>(lhs: V?, rhs: Expression<V?>) -> Expression<Bool?> where V.Datatype : Equatable {
    return lhs == rhs
}

//
//  Model.swift
//  AlamofireSQLReactiveSwift
//
//  Created by Robert John Alkuino on 3/27/20.
//  Copyright © 2020 Robert John Alkuino. All rights reserved.
//

import Foundation

typealias UUID = String

protocol ApiModel {
    var ID: UUID { get }
    var createdAt: Date { get }
    var updatedAt: Date { get }
}

protocol Model {
    var ID: UUID { get set }
    var createdAt: Date { get set }
    var updatedAt: Date { get set }
}

protocol MergeApiModel: Model {
    associatedtype AM: ApiModel
    
    mutating func mergeApiModel(apiModel: AM)
    static func newInstance() -> Self
    static func fromApiModel(apiModel: AM) -> Self
}

extension MergeApiModel {
    static func fromApiModel(apiModel: AM) -> Self {
        var model = newInstance()
        model.mergeApiModel(apiModel: apiModel)
        return model
    }
}

protocol DeletableModel: Model, Equatable {
    var deletedAt: NSDate? { get set }
}

extension Array where Element: Model {
    
    mutating func orderedInsert(newModel: Element, withOrder order: ComparisonResult) {
        // replace if already in array
        
        if let index = firstIndex(where: { $0.ID == newModel.ID }) {
            self[index] = newModel
            return
        }
        
        for (index, model) in self.enumerated() {
            if model.createdAt.compare(newModel.createdAt) != order {
                insert(newModel, at: index)
                return
            }
        }
        
        // append to end as fallback
        append(newModel)
    }
    
    func orderedMerge(newModels: Array, withOrder order: ComparisonResult) -> Array {
        var newArray = self
        
        for newModel in newModels {
            newArray.orderedInsert(newModel: newModel, withOrder: order)
        }
        
        return newArray
    }
    
}

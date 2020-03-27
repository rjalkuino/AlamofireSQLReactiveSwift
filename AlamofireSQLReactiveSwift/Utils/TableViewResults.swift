//
//  TableViewResults.swift
//  AlamofireSQLReactiveSwift
//
//  Created by Robert John Alkuino on 3/27/20.
//  Copyright © 2020 Robert John Alkuino. All rights reserved.
//

import Foundation

struct TableViewResults<T: DeletableModel> {
    let insert: [Int]
    let update: [Int]
    let delete: [Int]
    let models: [T]
    let changed: Bool
    
    static func empty() -> TableViewResults<T> {
        return TableViewResults<T>(insert: [], update: [], delete: [], models: [], changed: false)
    }
    func merge(newModels: [T], deleteOld: Bool) -> TableViewResults<T> {

        var models = self.models
        
        var delete: [Int] = []
        for deletedModel in newModels.filter({ $0.deletedAt != nil }) {
            if let index = models.firstIndex(where: { $0.ID == deletedModel.ID }) {
                delete.append(index)
            }
        }
        if deleteOld {
            for (index, model) in models.enumerated() {
                if newModels.firstIndex(where: { $0.ID == model.ID }) == nil {
                    delete.append(index)
                }
            }
        }
        
        for deleteIndex in delete.sorted().reversed() {
            models.remove(at: deleteIndex)
        }
        var update: [Int] = []
        var exclusiveNewModels: [T] = []
        for newModel in newModels.filter({ $0.deletedAt == nil }) {
            if let index = models.firstIndex(where: { $0.ID == newModel.ID }) {
                if models[index] != newModel {
                    update.append(index)
                    models[index] = newModel
                }
            } else {
                exclusiveNewModels.append(newModel)
            }
        }
        
        var insert: [Int] = []
        
        for newModel in exclusiveNewModels.sorted(by: { $0.createdAt > $1.createdAt }) {
            if let index = models.firstIndex(where: { $0.createdAt < newModel.createdAt }) {
                insert.append(index)
                models.insert(newModel, at: index)
            } else {
                insert.append(models.count)
                models.append(newModel)
            }
        }
        
        let changed = !insert.isEmpty || !update.isEmpty || !delete.isEmpty
        
        return TableViewResults(insert: insert, update: update, delete: delete, models: models, changed: changed)
    }
}




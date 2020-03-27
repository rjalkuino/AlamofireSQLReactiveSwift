//
//  ModelService.swift
//  AlamofireSQLReactiveSwift
//
//  Created by Robert John Alkuino on 3/27/20.
//  Copyright © 2020 Robert John Alkuino. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import ObjectMapper


class ModelBox<M: Model> {
    
    typealias ModelType = M
    
    fileprivate weak var cache: ModelCache<ModelType>?
    
    var model: ModelType
    
    var producer: SignalProducer<ModelType, Never> {
        return property.producer
    }
    
    fileprivate let property: MutableProperty<ModelType>
    
    fileprivate init(model: ModelType) {
        self.model = model
        property = MutableProperty(model)
    }
    
    func update(closure: (ModelBox) -> ()) {
        objc_sync_enter(self)
        closure(self)
        DispatchQueue.main.async {
            self.property.value = self.model
        }
        objc_sync_exit(self)
    }
    
    func replace(model: ModelType) {
        assert(model.ID == self.model.ID)
        objc_sync_enter(self)
        self.model = model
        DispatchQueue.main.async {
            self.property.value = model
        }
        objc_sync_exit(self)
    }
    
    func removeFromCache() {
        cache?.forget(uuid: model.ID)
    }
    
}

extension ModelBox where M: SQLiteModel {
    
    func insertOrUpdate() {
        objc_sync_enter(self)
        try! model.insertOrUpdate()
        DispatchQueue.main.async {
            self.property.value = self.model
        }
        objc_sync_exit(self)
    }
    
    func insertOrUpdate(closure: (ModelBox) -> ()) {
        objc_sync_enter(self)
        closure(self)
        try! model.insertOrUpdate()
        DispatchQueue.main.async {
            self.property.value = self.model
        }
        objc_sync_exit(self)
    }
    
}

class Models {
    static var persons = ModelCache<Person>()
    
}

protocol ModelCacheType: class {
    associatedtype ModelType: Model
    
    var cache: [UUID: ModelBox<ModelType>] { get set }
}

extension ModelCacheType {
    
    func create(model: ModelType) -> ModelBox<ModelType> {
        assert(cache[model.ID] == nil)
        cache[model.ID] = ModelBox(model: model)
        return cache[model.ID]!
    }
    
    func touch(model: ModelType) -> ModelBox<ModelType> {
        guard let box = cache[model.ID] else {
            return create(model: model)
        }
        
        if model.updatedAt > box.model.updatedAt {
            box.replace(model: model)
        }
        
        return box
    }
    
    func forget(uuid: UUID?) {
        if let uuid = uuid {
            cache.removeValue(forKey: uuid)
        }
    }
    
    subscript(uuid: UUID?) -> ModelBox<ModelType>? {
        get {
            guard let uuid = uuid else {
                return nil
            }
            return cache[uuid]
        }
    }
    
}

extension ModelCacheType where ModelType: MergeApiModel {
    
    func touch(apiModel: ApiModel) -> ModelBox<ModelType> {
        let apiModel = apiModel as! ModelType.AM
        
        if let box = cache[apiModel.ID]  {
            if apiModel.updatedAt > box.model.updatedAt {
                box.model.mergeApiModel(apiModel: apiModel)
            }
            return box
        }
        
        var model = ModelType.newInstance()
        model.mergeApiModel(apiModel: apiModel)
        
        return create(model: model)
    }
}

class ModelCache<M: Model>: ModelCacheType {
    typealias ModelType = M
    
    var cache: [UUID: ModelBox<ModelType>] = [:]
}

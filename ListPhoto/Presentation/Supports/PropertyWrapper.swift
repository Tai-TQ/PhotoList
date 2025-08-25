//
//  PropertyWrapper.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import Foundation
import Combine

@propertyWrapper
struct Property<Value> {
   
    var subject: CurrentValueSubject<Value, Never>
    private var lock = NSLock()
    
    public var wrappedValue: Value {
        get { return load() }
        set { store(newValue) }
    }
    
    public var projectedValue: CurrentValueSubject<Value, Never> {
        return self.subject
    }
    
    public init(wrappedValue: Value) {
        subject = CurrentValueSubject(wrappedValue)
    }
    
    func load() -> Value {
        lock.lock()
        defer { lock.unlock() }
        return subject.value
    }
    
    func store(_ newValue: Value) {
        lock.lock()
        defer { lock.unlock() }
        subject.send(newValue)
    }
}


@propertyWrapper
struct LoadingProperty<Value> {
   
    var subject: CurrentValueSubject<Value, Never>
    private var lock = NSLock()
    
    public var wrappedValue: Value {
        get { return load() }
        set { store(newValue) }
    }
    
    public var projectedValue: LoadingProperty<Value> {
        return self
    }
    
    public init(wrappedValue: Value) {
        subject = CurrentValueSubject(wrappedValue)
    }
    
    func load() -> Value {
        lock.lock()
        defer { lock.unlock() }
        return subject.value
    }
    
    func store(_ newValue: Value) {
        lock.lock()
        defer { lock.unlock() }
        subject.send(newValue)
    }
}

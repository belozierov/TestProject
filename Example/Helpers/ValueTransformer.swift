//
//  ValueTransformer.swift
//  Example
//
//  Created by Alex Belozierov on 8/29/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation

extension ValueTransformer {
    
    private class _ValueTransformer: ValueTransformer {
        
        let transformer: (Any?) -> Any?
        
        init(transformer: @escaping (Any?) -> Any?) {
            self.transformer = transformer
        }
        
        override func transformedValue(_ value: Any?) -> Any? {
            transformer(value)
        }
        
    }
    
    static func register(name: NSValueTransformerName, transformer: @escaping (Any?) -> Any?) {
        let transformer = _ValueTransformer(transformer: transformer)
        setValueTransformer(transformer, forName: name)
    }
    
    static func register(name: String, transformer: @escaping (Any?) -> Any?) {
        let name = NSValueTransformerName(rawValue: name)
        register(name: name, transformer: transformer)
    }
    
    static func transform(value: Any?, name: NSValueTransformerName) -> Any? {
        ValueTransformer(forName: name)?.transformedValue(value)
    }
    
    static func transform(value: Any?, name: String) -> Any? {
        let name = NSValueTransformerName(rawValue: name)
        return transform(value: value, name: name)
    }
    
}

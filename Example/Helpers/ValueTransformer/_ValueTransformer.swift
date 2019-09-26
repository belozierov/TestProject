//
//  ValueTransformer.swift
//  Example
//
//  Created by Alex Belozierov on 8/29/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation

class _ValueTransformer: ValueTransformer {
    
    let transformer: (Any?) -> Any?
    
    @objc init(transformer: @escaping (Any?) -> Any?) {
        self.transformer = transformer
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        transformer(value)
    }
    
}

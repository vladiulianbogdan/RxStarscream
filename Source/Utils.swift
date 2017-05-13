//
//  Utils.swift
//
//  Created by Bogdan Vlad on 5/13/17.
//  Copyright © 2017 Bogdan Vlad. All rights reserved.
//

struct Utils {
    static func castOrFatalError<T>(_ value: Any!) -> T {
        let maybeResult: T? = value as? T
        guard let result = maybeResult else {
            preconditionFailure("Failure converting from \(value) to \(T.self)")
        }
        
        return result
    }
    
    static func castOptionalOrFatalError<T>(_ value: Any?) -> T? {
        if value == nil {
            return nil
        }
        let v: T = castOrFatalError(value)
        return v
    }
}

//
//  BoolExtension.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-19.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

extension Bool {
    /// Logical xor operator for Bool.
    static func ^ (rhs: Bool, lhs: Bool) -> Bool {
        return (rhs || lhs) && !(rhs && lhs)
    }
}

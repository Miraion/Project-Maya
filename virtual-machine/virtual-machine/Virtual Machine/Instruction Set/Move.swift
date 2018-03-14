//
//  Mov.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class Move : BasicBinaryInstruction, ModdableInstruction, BinaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) {
        dst.copy(src, as: T.self)
    }
}

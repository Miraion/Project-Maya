//
//  Mov.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class Mov : BasicBinaryInstruction, BinaryInstruction {
    func run() {
        dst.copy(src)
    }
}

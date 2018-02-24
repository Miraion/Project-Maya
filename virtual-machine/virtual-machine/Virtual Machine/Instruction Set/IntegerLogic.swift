//
//  IntegerLogic.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class And : BasicTernaryInstruction, TernaryInstruction {
    func run() {
        dstReg.quad = srcRegA.quad & srcRegB.quad
    }
}

class Or : BasicTernaryInstruction, TernaryInstruction {
    func run() {
        dstReg.quad = srcRegA.quad | srcRegB.quad
    }
}

class Xor : BasicTernaryInstruction, TernaryInstruction {
    func run() {
        dstReg.quad = srcRegA.quad ^ srcRegB.quad
    }
}

class Not : BasicBinaryInstruction, BinaryInstruction {
    func run() {
        dst.quad = ~src.quad
    }
}

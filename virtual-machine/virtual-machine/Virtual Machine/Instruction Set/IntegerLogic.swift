//
//  IntegerLogic.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class And : BasicTernaryInstruction, ModdableInstruction, TernaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) {
        dstReg.set(srcRegA.get(as: T.self) & srcRegB.get(as: T.self))
    }
}

class Or : BasicTernaryInstruction, ModdableInstruction, TernaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) {
        dstReg.set(srcRegA.get(as: T.self) | srcRegB.get(as: T.self))
    }
}

class Xor : BasicTernaryInstruction, ModdableInstruction, TernaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) {
        dstReg.set(srcRegA.get(as: T.self) ^ srcRegB.get(as: T.self))
    }
}

class Not : BasicBinaryInstruction, ModdableInstruction, BinaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) {
        dst.set(~src.get(as: T.self))
    }
}

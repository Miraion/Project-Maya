//
//  IntegerArithmatic.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class Add : BasicTernaryInstruction, TernaryInstruction {
    func run() {
        let x = srcRegA.quad.addingReportingOverflow(srcRegB.quad)
        dstReg.set(x.partialValue)
        VPU.OF = x.overflow
    }
}

class Sub : BasicTernaryInstruction, TernaryInstruction {
    func run() {
        let x = srcRegA.quad.subtractingReportingOverflow(srcRegB.quad)
        dstReg.set(x.partialValue)
        VPU.OF = x.overflow
    }
}

class Mul : BasicTernaryInstruction, TernaryInstruction {
    func run() {
        let x = srcRegA.quad.multipliedReportingOverflow(by: srcRegB.quad)
        dstReg.set(x.partialValue)
        VPU.OF = x.overflow
    }
}

class Div : BasicTernaryInstruction, TernaryInstruction {
    func run() {
        let x = srcRegA.quad.dividedReportingOverflow(by: srcRegB.quad)
        dstReg.set(x.partialValue)
       VPU.OF = x.overflow
    }
}

class Neg : BasicBinaryInstruction, BinaryInstruction {
    func run() {
        let x = -src.get(as: SignedQuad.self)
        dst.set(x)
    }
}

class Inc : BasicUnaryInstruction, UnaryInstruction {
    func run() {
        let x = src.quad.addingReportingOverflow(1)
        src.quad = x.partialValue
        VPU.OF = x.overflow
    }
}

class Dec : BasicUnaryInstruction, UnaryInstruction {
    func run() {
        let x = src.quad.subtractingReportingOverflow(1)
        src.quad = x.partialValue
        VPU.OF = x.overflow
    }
}

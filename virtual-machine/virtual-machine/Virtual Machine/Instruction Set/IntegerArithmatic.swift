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

class ImmAdd<I: FixedWidthInteger> : ImmediateInstruction {
    var reg = VirtualRegister()
    var extractor: FileDecoder? = nil
    
    func setup(reg: VirtualRegister, extractor: FileDecoder) {
        self.reg = reg
        self.extractor = extractor
    }
    
    func run() throws {
        if let x = extractor!.extract(as: I.self) {
            let y = reg.get(as: I.self)
            let z = x.addingReportingOverflow(y)
            reg.set(z.partialValue)
            VPU.OF = z.overflow
        } else {
            throw VirtualMachine.RuntimeError.SegmentationFault
        }
    }
}

class ImmSub<I: FixedWidthInteger> : ImmediateInstruction {
    var reg = VirtualRegister()
    var extractor: FileDecoder? = nil
    
    func setup(reg: VirtualRegister, extractor: FileDecoder) {
        self.reg = reg
        self.extractor = extractor
    }
    
    func run() throws {
        if let x = extractor!.extract(as: I.self) {
            let y = reg.get(as: I.self)
            let z = y.subtractingReportingOverflow(x)
            reg.set(z.partialValue)
            VPU.OF = z.overflow
        } else {
            throw VirtualMachine.RuntimeError.SegmentationFault
        }
    }
}

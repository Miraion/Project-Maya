//
//  IntegerArithmatic.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class IntegerAddition : BasicTernaryInstruction, ModdableInstruction, TernaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) {
        let x = srcRegA.get(as: T.self).addingReportingOverflow(srcRegB.get(as: T.self))
        dstReg.set(x.partialValue)
        VPU.OF = x.overflow
    }
}


class IntegerSubtraction : BasicTernaryInstruction, ModdableInstruction, TernaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) {
        let x = srcRegA.get(as: T.self).subtractingReportingOverflow(srcRegB.get(as: T.self))
        dstReg.set(x.partialValue)
        VPU.OF = x.overflow
    }
}


class IntegerMultiplication : BasicTernaryInstruction, ModdableInstruction, TernaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) {
        let x = srcRegA.get(as: T.self).multipliedReportingOverflow(by: srcRegB.get(as: T.self))
        dstReg.set(x.partialValue)
        VPU.OF = x.overflow
    }
}


class IntegerDivision : BasicTernaryInstruction, ModdableInstruction, TernaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) {
        let x = srcRegA.get(as: T.self).dividedReportingOverflow(by: srcRegB.get(as: T.self))
        dstReg.set(x.partialValue)
       VPU.OF = x.overflow
    }
}


class IntegerModulo : BasicTernaryInstruction, ModdableInstruction, TernaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) {
        let x = srcRegA.get(as: T.self).remainderReportingOverflow(dividingBy: srcRegB.get(as: T.self))
        dstReg.set(x.partialValue)
        VPU.OF = x.overflow
    }
}


class IntegerNegation : BasicBinaryInstruction, ModdableInstruction, BinaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) {
        let x = T(0).subtractingReportingOverflow(src.get(as: T.self))
        VPU.OF = x.overflow
        dst.set(x.partialValue)
    }
}


class Increment : ModdableInstruction, ImmediateInstruction {
    var reg = VirtualRegister()
    var extractor: FileDecoder? = nil
    var modifier: UInt8 = 0
    
    func setup(reg: VirtualRegister, extractor: FileDecoder) {
        self.reg = reg
        self.extractor = extractor
    }
    
    func run<T: FixedWidthInteger>(as: T.Type) throws {
        if let x = extractor?.extract(as: T.self) {
            let y = reg.get(as: T.self).addingReportingOverflow(x)
            reg.set(y.partialValue)
            VPU.OF = y.overflow
        } else {
            throw VirtualMachine.RuntimeError.SegmentationFault
        }
    }
}


class Decrement : ModdableInstruction, ImmediateInstruction {
    var reg = VirtualRegister()
    var extractor: FileDecoder? = nil
    var modifier: UInt8 = 0
    
    func setup(reg: VirtualRegister, extractor: FileDecoder) {
        self.reg = reg
        self.extractor = extractor
    }
    
    func run<T: FixedWidthInteger>(as: T.Type) throws {
        if let x = extractor?.extract(as: T.self) {
            let y = reg.get(as: T.self).subtractingReportingOverflow(x)
            reg.set(y.partialValue)
            VPU.OF = y.overflow
        } else {
            throw VirtualMachine.RuntimeError.SegmentationFault
        }
    }
}


class ShiftLeft : BasicTernaryInstruction, ModdableInstruction, TernaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) {
        let src = srcRegA.get(as: T.self)
        let ammount = srcRegB.get(as: T.self)
        let result = src.shiftingLeftReportingOverflow(ammount)
        dstReg.set(result.partialValue)
        VPU.OF = result.overflow
        VPU.CF = result.overflow
    }
}


class ShiftRight : BasicTernaryInstruction, ModdableInstruction, TernaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) {
        let src = srcRegA.get(as: T.self)
        let ammount = srcRegB.get(as: T.self)
        let result = src.shiftingRightReportingOverflow(ammount)
        dstReg.set(result.partialValue)
        VPU.OF = result.overflow
        VPU.CF = result.overflow
    }
}

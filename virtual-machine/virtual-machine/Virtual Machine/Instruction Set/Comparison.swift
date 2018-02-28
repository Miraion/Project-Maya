//
//  Comparison.swift
//  virtual-machine
//
//  Created by Jeremy S on 2018-02-24.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class Cmp : BasicBinaryInstruction, BinaryInstruction {
    func run() {
        let result = src.get(as: SignedQuad.self).subtractingReportingOverflow(dst.get(as: SignedQuad.self))
        VPU.ZF = result.partialValue == 0
        VPU.OF = result.overflow
        VPU.SF = result.partialValue < 0
        
        let unsignedResult = src.quad.subtractingReportingOverflow(dst.quad)
        VPU.CF = unsignedResult.overflow
    }
}

class Cast<I: FixedWidthInteger> : BasicUnaryInstruction, UnaryInstruction {
    func run() {
        VPU.OF = src.quad > I.max
        VPU.ZF = src.quad == 0
    }
}

class TestZ : BasicUnaryInstruction, UnaryInstruction {
    func run() {
        VPU.ZF = src.quad == 0
    }
}

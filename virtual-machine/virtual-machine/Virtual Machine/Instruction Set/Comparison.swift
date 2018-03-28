//
//  Comparison.swift
//  virtual-machine
//
//  Created by Jeremy S on 2018-02-24.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class Compare : BasicBinaryInstruction, ModdableInstruction, BinaryInstruction {
    func compareSigned<T: FixedWidthInteger>(_ type: T.Type) {
        let a = src.get(as: T.self)
        let b = dst.get(as: T.self)
        
        // vv Find a better way to do this vv //
        if let x = a as? UInt8 {
            let y = b as! UInt8
            let signedX = Int8(bitPattern: x)
            let signedY = Int8(bitPattern: y)
            let result = signedX.subtractingReportingOverflow(signedY)
            VPU.ZF = result.partialValue == 0
            VPU.OF = result.overflow
            VPU.SF = result.partialValue < 0
        } else if let x = a as? UInt16 {
            let y = b as! UInt16
            let signedX = Int16(bitPattern: x)
            let signedY = Int16(bitPattern: y)
            let result = signedX.subtractingReportingOverflow(signedY)
            VPU.ZF = result.partialValue == 0
            VPU.OF = result.overflow
            VPU.SF = result.partialValue < 0
        } else if let x = a as? UInt32 {
            let y = b as! UInt32
            let signedX = Int32(bitPattern: x)
            let signedY = Int32(bitPattern: y)
            let result = signedX.subtractingReportingOverflow(signedY)
            VPU.ZF = result.partialValue == 0
            VPU.OF = result.overflow
            VPU.SF = result.partialValue < 0
        } else if let x = a as? UInt64 {
            let y = b as! UInt64
            let signedX = Int64(bitPattern: x)
            let signedY = Int64(bitPattern: y)
            let result = signedX.subtractingReportingOverflow(signedY)
            VPU.ZF = result.partialValue == 0
            VPU.OF = result.overflow
            VPU.SF = result.partialValue < 0
        }
    }
    
    
    func run<T: FixedWidthInteger>(as: T.Type) {
        compareSigned(T.self)
        
        let unsignedResult = src.get(as: T.self).subtractingReportingOverflow(dst.get(as: T.self))
        VPU.CF = unsignedResult.overflow
    }
}


class TestZero : BasicUnaryInstruction, UnaryInstruction {
    func run() {
        VPU.ZF = src.quad == 0
        VPU.SF = Int64(bitPattern: src.quad) < 0
    }
}

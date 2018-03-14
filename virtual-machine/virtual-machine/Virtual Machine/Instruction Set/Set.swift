//
//  Set.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class Set : ModdableInstruction, ImmediateInstruction {
    var reg = VirtualRegister()
    var extractor: FileDecoder? = nil
    var modifier: UInt8 = 0
    
    func setup(reg: VirtualRegister, extractor: FileDecoder) {
        self.reg = reg
        self.extractor = extractor
    }
    
    func run<T: FixedWidthInteger>(as: T.Type) throws {
        if let x = extractor?.extract(as: T.self) {
            reg.set(x)
        } else {
            throw VirtualMachine.RuntimeError.SegmentationFault
        }
    }
}


class Zero : BasicUnaryInstruction, UnaryInstruction {
    func run() {
        src.zero()
    }
}

//
//  Set.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class Set<T: FixedWidthInteger> : ImmediateInstruction {
    
    var reg = VirtualRegister()
    var extractor: FileDecoder? = nil
    
    func setup(reg: VirtualRegister, extractor: FileDecoder) {
        self.reg = reg
        self.extractor = extractor
    }
    
    func run() throws {
        if let x = extractor!.extract(as: T.self) {
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

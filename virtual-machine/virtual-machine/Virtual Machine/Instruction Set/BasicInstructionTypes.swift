//
//  BasicInstructionTypes.swift
//  virtual-machine
//
//  Created by Jeremy S on 2018-03-05.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

protocol ModdableInstruction : Instruction {
    var modifier: UInt8 { set get }
    
    func run<T: FixedWidthInteger>(as: T.Type) throws
}

extension ModdableInstruction {
    func run() throws {
        switch (modifier) {
        case 1: try run(as: Byte.self)
        case 2: try run(as: Word.self)
        case 3: try run(as: Long.self)
        case 4: try run(as: Quad.self)
        default: throw VirtualMachine.RuntimeError.InvalidModifier(mod: modifier)
        }
    }
    
    mutating func set(modifier: UInt8) {
        self.modifier = modifier
    }
}

class BasicUnaryInstruction {
    var src = VirtualRegister()
    var modifier: UInt8 = 0
    
    func setup(src: VirtualRegister/*, modifier: UInt8 */) {
        self.src = src
//        self.modifier = modifier
    }
}

class BasicBinaryInstruction {
    var src = VirtualRegister()
    var dst = VirtualRegister()
    var modifier: UInt8 = 0
    
    func setup(srca: VirtualRegister, dst: VirtualRegister/*, modifier: UInt8 */) {
        self.src = srca
        self.dst = dst
//        self.modifier = modifier
    }
}

class BasicTernaryInstruction {
    var srcRegA = VirtualRegister()
    var srcRegB = VirtualRegister()
    var dstReg  = VirtualRegister()
    var modifier: UInt8 = 0
    
    func setup(srca: VirtualRegister, srcb: VirtualRegister, dst: VirtualRegister/*, modifier: UInt8 */) {
        self.srcRegA = srca
        self.srcRegB = srcb
        self.dstReg = dst
//        self.modifier = modifier
    }
}

class BasicUnaryAddrInstruction {
    var addr: Quad = 0
    
    func setup(addr: Quad) {
        self.addr = addr
    }
}

class BasicBinaryAddrInstruction {
    var reg = VirtualRegister()
    var addr: Quad = 0
    
    func setup(reg: VirtualRegister, addr: Quad) {
        self.reg = reg
        self.addr = addr
    }
}


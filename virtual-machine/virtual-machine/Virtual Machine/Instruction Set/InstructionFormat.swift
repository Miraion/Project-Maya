//
//  InstructionFormat.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

protocol Instruction {
    func run() throws
}

protocol VoidInstruction : Instruction {}

protocol UnaryInstruction : Instruction {
    func setup(src: VirtualRegister)
}

protocol BinaryInstruction : Instruction {
    func setup(srca: VirtualRegister, dst: VirtualRegister)
}

protocol TernaryInstruction : Instruction {
    func setup(srca: VirtualRegister, srcb: VirtualRegister, dst: VirtualRegister)
}

protocol UnaryAddrInstruction : Instruction {
    func setup(addr: Quad)
}

protocol BinaryAddrInstruction : Instruction {
    func setup(reg: VirtualRegister, addr: Quad)
}

protocol ImmediateInstruction : Instruction {
    func setup(reg: VirtualRegister, extractor: FileDecoder)
}


class BasicUnaryInstruction {
    var src = VirtualRegister()
    
    func setup(src: VirtualRegister) {
        self.src = src
    }
}

class BasicBinaryInstruction {
    var src = VirtualRegister()
    var dst = VirtualRegister()
    
    func setup(srca: VirtualRegister, dst: VirtualRegister) {
        self.src = srca
        self.dst = dst
    }
}

class BasicTernaryInstruction {
    var srcRegA = VirtualRegister()
    var srcRegB = VirtualRegister()
    var dstReg  = VirtualRegister()
    
    func setup(srca: VirtualRegister, srcb: VirtualRegister, dst: VirtualRegister) {
        self.srcRegA = srca
        self.srcRegB = srcb
        self.dstReg = dst
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

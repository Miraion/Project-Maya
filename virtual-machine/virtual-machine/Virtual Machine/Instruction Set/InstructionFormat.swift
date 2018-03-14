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
    func setup(src: VirtualRegister/*, modifier: UInt8*/)
}

protocol BinaryInstruction : Instruction {
    func setup(srca: VirtualRegister, dst: VirtualRegister/*, modifier: UInt8*/)
}

protocol TernaryInstruction : Instruction {
    func setup(srca: VirtualRegister, srcb: VirtualRegister, dst: VirtualRegister/*, modifier: UInt8*/)
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

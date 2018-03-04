//
//  Jump.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class Jmp : BasicUnaryAddrInstruction, UnaryAddrInstruction {
    func run() {
        let x = SignedQuad(bitPattern: addr)
        var pc = SignedQuad(bitPattern: VPU.PC)
        pc += x
        VPU.PC = Quad(bitPattern: pc)
    }
}

class ConditionalJump : BasicUnaryAddrInstruction, UnaryAddrInstruction {
    var condition: () -> Bool
    
    init (_ condition: @escaping () -> Bool) {
        self.condition = condition
    }
    
    func run() {
        if condition() {
            let x = SignedQuad(bitPattern: addr)
            var pc = SignedQuad(bitPattern: VPU.PC)
            pc += x
            VPU.PC = Quad(bitPattern: pc)
        }
    }
}

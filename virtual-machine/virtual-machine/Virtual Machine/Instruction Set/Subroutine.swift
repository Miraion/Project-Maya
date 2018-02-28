//
//  Subroutine.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class Call : BasicUnaryAddrInstruction, UnaryAddrInstruction {
    func run() throws {
        if VPU.rs.quad >= (VM.bottomOfCallStackAddr + 8) {
            VPU.rs.quad -= 8
            if let ptr = UnsafeMutablePointer<Quad>(bitPattern: UInt(VPU.rs.quad)) {
                ptr.pointee = VPU.PC  // push program counter
                VPU.PC = VM.codeAddress + addr  // jump to label
            } else {
                throw VirtualMachine.RuntimeError.SegmentationFault
            }
        } else {
            throw VirtualMachine.RuntimeError.StackOverflow
        }
    }
}

class Return : VoidInstruction {
    func run() throws {
        if VPU.rs.quad <= (VM.initialStackPointer - 8) {
            if let ptr = UnsafePointer<Quad>(bitPattern: UInt(VPU.rs.quad)) {
                VPU.PC = ptr.pointee  // restore program counter
                VPU.rs.quad += 8
            } else {
                throw VirtualMachine.RuntimeError.SegmentationFault
            }
        } else {
            throw VirtualMachine.RuntimeError.SegmentationFault
        }
    }
}

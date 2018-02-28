//
//  MemoryInterface.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class Push : BasicUnaryInstruction, UnaryInstruction {
    func run() throws {
        if VPU.rs.quad >= (VM.bottomOfCallStackAddr + 8) {
            VPU.rs.quad -= 8
            if let ptr = UnsafeMutablePointer<Quad>(bitPattern: UInt(VPU.rs.quad)) {
                ptr.pointee = src.quad
            } else {
                throw VirtualMachine.RuntimeError.SegmentationFault
            }
        } else {
            throw VirtualMachine.RuntimeError.StackOverflow
        }
    }
}

class Pop : BasicUnaryInstruction, UnaryInstruction {
    func run() throws {
        if VPU.rs.quad <= (VM.initialStackPointer - 8) {
            if let ptr = UnsafePointer<Quad>(bitPattern: UInt(VPU.rs.quad)) {
                src.quad = ptr.pointee
                VPU.rs.quad += 8
            } else {
                throw VirtualMachine.RuntimeError.SegmentationFault
            }
        } else {
            throw VirtualMachine.RuntimeError.SegmentationFault
        }
    }
}

class LoadFromImmediate<T: FixedWidthInteger> : BasicBinaryAddrInstruction, BinaryAddrInstruction {
    func run() throws {
        addr += VM.codeAddress
        if let rawPtr = UnsafeRawPointer(bitPattern: UInt(addr)) {
            let ptr = rawPtr.bindMemory(to: T.self, capacity: 1)
            let x = ptr.pointee.littleEndian
            reg.set(x)
        } else {
            throw SystemInterface.RuntimeError.BadAccess(addr: addr)
        }
    }
}

class LoadAddress : BasicBinaryAddrInstruction, BinaryAddrInstruction {
    func run() {
        addr += VM.codeAddress
        reg.set(addr)
    }
}

class Load<T: FixedWidthInteger> : BasicBinaryInstruction, BinaryInstruction {
    func run() throws {
        let addr = src.quad
        if let rawPtr = UnsafeRawPointer(bitPattern: UInt(addr)) {
            let ptr = rawPtr.bindMemory(to: T.self, capacity: 1)
            let x = ptr.pointee.littleEndian
            dst.set(x)
        } else {
            throw SystemInterface.RuntimeError.BadAccess(addr: addr)
        }
    }
}

class Store<T: FixedWidthInteger> : BasicBinaryInstruction, BinaryInstruction {
    func run() throws {
        let addr = dst.quad
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: UInt(addr)) {
            let ptr = rawPtr.bindMemory(to: T.self, capacity: 1)
            let x = src.get(as: T.self)
            ptr.pointee = x.littleEndian
        } else {
            throw SystemInterface.RuntimeError.BadAccess(addr: addr)
        }
    }
}

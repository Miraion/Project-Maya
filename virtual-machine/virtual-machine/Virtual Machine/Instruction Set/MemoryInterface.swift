//
//  MemoryInterface.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

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

//
//  MemoryInterface.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class Push : BasicUnaryInstruction, ModdableInstruction, UnaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) throws {
        if VPU.rs.quad >= (VM.bottomOfCallStackAddr + Quad(MemoryLayout<T>.size)) {
            VPU.rs.quad -= Quad(MemoryLayout<T>.size)
            if let ptr = UnsafeMutablePointer<T>(bitPattern: UInt(VPU.rs.quad)) {
                ptr.pointee = src.get(as: T.self)
            } else {
                throw VirtualMachine.RuntimeError.SegmentationFault
            }
        } else {
            throw VirtualMachine.RuntimeError.SegmentationFault
        }
    }
}


class Pop : BasicUnaryInstruction, ModdableInstruction, UnaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) throws {
        if VPU.rs.quad >= (VM.bottomOfCallStackAddr + Quad(MemoryLayout<T>.size)) {
            if let ptr = UnsafeMutablePointer<T>(bitPattern: UInt(VPU.rs.quad)) {
                src.set(ptr.pointee)
                VPU.rs.quad += Quad(MemoryLayout<T>.size)
            } else {
                throw VirtualMachine.RuntimeError.SegmentationFault
            }
        } else {
            throw VirtualMachine.RuntimeError.SegmentationFault
        }
    }
}


class LoadDirect : BasicBinaryAddrInstruction, ModdableInstruction, BinaryAddrInstruction {
    var modifier: UInt8 = 0
    
    func run<T: FixedWidthInteger>(as: T.Type) throws {
        addr += VPU.PC
        if let rawPtr = UnsafeRawPointer(bitPattern: UInt(addr)) {
            let ptr = rawPtr.bindMemory(to: T.self, capacity: 1)
            let x = ptr.pointee
            reg.set(x)
        } else {
            throw SystemInterface.RuntimeError.BadAccess(addr: addr)
        }
    }
}


class LoadIndirect : BasicBinaryInstruction, ModdableInstruction, BinaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) throws {
        let addr = src.quad
        if let rawPtr = UnsafeRawPointer(bitPattern: UInt(addr)) {
            let ptr = rawPtr.bindMemory(to: T.self, capacity: 1)
            let x = ptr.pointee
            dst.set(x)
        } else {
            throw SystemInterface.RuntimeError.BadAccess(addr: addr)
        }
    }
}


class StoreDirect : BasicBinaryAddrInstruction, ModdableInstruction, BinaryAddrInstruction {
    var modifier: UInt8 = 0
    
    func run<T: FixedWidthInteger>(as: T.Type) throws {
        addr += VPU.PC
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: UInt(addr)) {
            let ptr = rawPtr.bindMemory(to: T.self, capacity: 1)
            ptr.pointee = reg.get(as: T.self).bigEndian
        } else {
            throw SystemInterface.RuntimeError.BadAccess(addr: addr)
        }
    }
}


class StoreIndirect : BasicBinaryInstruction, ModdableInstruction, BinaryInstruction {
    func run<T: FixedWidthInteger>(as: T.Type) throws {
        let addr = dst.quad
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: UInt(addr)) {
            let ptr = rawPtr.bindMemory(to: T.self, capacity: 1)
            ptr.pointee = src.get(as: T.self).bigEndian
        } else {
            throw SystemInterface.RuntimeError.BadAccess(addr: addr)
        }
    }
}


class LoadAddress : BasicBinaryAddrInstruction, BinaryAddrInstruction {
    func run() {
        reg.quad = VPU.PC + addr
    }
}

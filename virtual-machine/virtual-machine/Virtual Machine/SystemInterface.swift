//
//  SystemInterface.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation
import Darwin.C

class SystemInterface {
    
    var externalAllocatedMemory = Swift.Set<Quad>()
    
    
    enum RuntimeError : Error {
        case BadAccess(addr: Quad)
    }
    
    
    func write(outputDevice: Quad, bufferAddr: Quad, size: Quad) throws -> Int {
        if let charPtr = UnsafeRawPointer(bitPattern: UInt(bufferAddr)) {
            return Darwin.write(Int32(truncatingIfNeeded: outputDevice), charPtr, Int(size))
        } else {
            throw RuntimeError.BadAccess(addr: bufferAddr)
        }
    }
    
    
    func read(inputDevice: Quad, bufferAddr: Quad, capacity: Quad) throws -> Int {
        if let buf = UnsafeMutableRawPointer(bitPattern: UInt(bufferAddr)) {
            return Darwin.read(Int32(truncatingIfNeeded: inputDevice), buf, Int(capacity))
        } else {
            throw RuntimeError.BadAccess(addr: bufferAddr)
        }
    }
    
    
    func debugVPUStatus(mode: Quad) -> Int {
        if mode == 0 {
            VPU.printDec()
            return 0
        } else if mode == 1 {
            VPU.printHex()
            return 0
        } else {
            return -1
        }
    }
    
    
    func debugStackState(size: Quad) -> Int {
        for i in 0..<Int(size) {
            let ptr = UnsafePointer<Byte>(bitPattern: Int(VM.stackAddress) - (i * 8))!
            var bytes = [UInt8]()
            for j in 0...7 {
                bytes.append(ptr.advanced(by: -j).pointee)
            }
            let label = String(format: "-0x%04lx:", i * 8)
            let format = "%02x"
            print(label, terminator: " ")
            for byte in bytes {
                print(String(format: format, byte), terminator: " ")
            }
            print()
        }
        return 0
    }
    
    
    func finishExecution(exitCode: Quad) {
        VM.continueExecution = false
        VM.exitCode = Int(bitPattern: UInt(exitCode))
    }
    
    
    func abortExecution(exitCode: Long) {
        exit(Int32(bitPattern: exitCode))
    }
    
    
    func allocate(capacity: Quad) throws -> Quad {
        if let ptr = malloc(Int(capacity)) {
            let addr = Quad(UInt(bitPattern: ptr))
            externalAllocatedMemory.insert(addr)
            return addr
        } else {
            throw VirtualMachine.RuntimeError.SegmentationFault
        }
    }
    
    
    func deallocate(addr: Quad) throws {
        if externalAllocatedMemory.remove(addr) != nil {
            let ptr = UnsafeMutableRawPointer(bitPattern: UInt(addr))
            free(ptr)
        } else {
            throw VirtualMachine.RuntimeError.FreeUnallocatedAddress(addr: addr)
        }
    }
    
    
    func open(path: UnsafeRawPointer, mode: Int32) -> Int32 {
        return Darwin.open(path.assumingMemoryBound(to: CChar.self), mode)
    }
    
    
    func close(fd: Int32) -> Int32 {
        return Darwin.close(fd)
    }
    
}
